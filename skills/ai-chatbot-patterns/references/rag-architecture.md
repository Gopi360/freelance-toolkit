# RAG Architecture Reference

## When to Use RAG

- Customer support bots answering questions from a knowledge base
- Internal document assistants (SOPs, policies, product info)
- FAQ bots where answers change frequently
- Any chatbot that needs to reference specific, factual content

## Architecture

```
INGESTION PIPELINE (run once, update periodically):
  Documents (PDF/Markdown/HTML/CSV)
    → Chunking (500 tokens, 50 token overlap)
    → Embedding (OpenAI text-embedding-3-small or Gemini embedding)
    → Vector Store (Pinecone / Supabase pgvector / ChromaDB)

QUERY PIPELINE (per user message):
  User Message
    → Embed query
    → Vector similarity search (top 5 chunks)
    → Build prompt: system + context chunks + user question
    → LLM generates answer
    → Confidence check (similarity score > 0.7?)
      → High confidence: return answer
      → Low confidence: "I'm not sure, let me connect you with a team member"
```

## n8n Implementation

### Ingestion Workflow
```
Manual Trigger / Schedule Trigger
  → HTTP Request: Fetch documents (or Read File node)
  → Code: Chunk documents
  → Loop: For each chunk
    → HTTP Request: POST to embedding API
    → HTTP Request: Upsert to vector store
  → Code: Log ingestion summary
```

### Chunking Code Node
```typescript
const items = $input.all();
const CHUNK_SIZE = 500; // tokens (~2000 chars)
const OVERLAP = 50;     // tokens (~200 chars)
const CHAR_PER_TOKEN = 4; // rough approximation

const chunks: any[] = [];

for (const item of items) {
  const text = item.json.content || item.json.text || '';
  const source = item.json.source || item.json.filename || 'unknown';
  const chunkSizeChars = CHUNK_SIZE * CHAR_PER_TOKEN;
  const overlapChars = OVERLAP * CHAR_PER_TOKEN;

  // Split by paragraphs first for cleaner chunks
  const paragraphs = text.split(/\n\n+/);
  let currentChunk = '';
  let chunkIndex = 0;

  for (const para of paragraphs) {
    if ((currentChunk + para).length > chunkSizeChars && currentChunk.length > 0) {
      chunks.push({
        json: {
          text: currentChunk.trim(),
          source,
          chunk_index: chunkIndex,
          char_count: currentChunk.trim().length,
        }
      });
      // Keep overlap from end of current chunk
      currentChunk = currentChunk.slice(-overlapChars) + '\n\n' + para;
      chunkIndex++;
    } else {
      currentChunk += (currentChunk ? '\n\n' : '') + para;
    }
  }

  // Don't forget the last chunk
  if (currentChunk.trim()) {
    chunks.push({
      json: {
        text: currentChunk.trim(),
        source,
        chunk_index: chunkIndex,
        char_count: currentChunk.trim().length,
      }
    });
  }
}

return chunks;
```

### Query Workflow
```
Webhook: Receive user question
  → Respond to Webhook (200, "processing")
  → HTTP Request: Embed user question
  → HTTP Request: Query vector store (top 5)
  → Code: Build RAG prompt
  → HTTP Request: LLM call
  → Code: Check confidence + format response
  → HTTP Request: Send reply
```

### RAG Prompt Builder Code Node
```typescript
const question = $input.first().json.question;
const searchResults = $('Query Vector Store').first().json;

// Extract context chunks
const contexts = (searchResults.matches || searchResults.results || [])
  .filter((match: any) => (match.score || match.similarity || 0) > 0.7)
  .map((match: any, i: number) => {
    const text = match.metadata?.text || match.text || match.content || '';
    const source = match.metadata?.source || 'unknown';
    return `[Source ${i + 1}: ${source}]\n${text}`;
  })
  .join('\n\n---\n\n');

const hasGoodContext = contexts.length > 0;

const systemPrompt = `You are a helpful customer support assistant for [CLIENT_BRAND].

Answer the user's question using ONLY the provided context. If the context doesn't
contain enough information to answer confidently, say: "I don't have enough information
to answer that confidently. Let me connect you with someone who can help."

RULES:
- Only use facts from the provided context
- Never make up information
- Be concise — 2-3 sentences max unless the question requires detail
- If referencing specific policies or procedures, mention the source

CONTEXT:
${hasGoodContext ? contexts : 'No relevant context found.'}`;

return [{
  json: {
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: question },
    ],
    has_context: hasGoodContext,
    context_count: (searchResults.matches || searchResults.results || []).length,
  }
}];
```

## Vector Store Options

| Store | Best For | Cost | n8n Integration |
|---|---|---|---|
| **Pinecone** | Production, managed | Free tier: 1 index | HTTP Request (REST API) |
| **Supabase pgvector** | If already using Supabase | Free tier available | HTTP Request or Supabase node |
| **ChromaDB** | Self-hosted, local dev | Free (self-hosted) | HTTP Request to local server |
| **Qdrant** | High performance, self-hosted | Free (self-hosted) | HTTP Request (REST API) |

## Embedding Models

| Model | Dimensions | Cost | Best For |
|---|---|---|---|
| OpenAI `text-embedding-3-small` | 1536 | $0.02/1M tokens | Default choice, good quality/cost |
| OpenAI `text-embedding-3-large` | 3072 | $0.13/1M tokens | Higher accuracy, higher cost |
| Gemini `text-embedding-004` | 768 | Free tier generous | Budget-friendly, good enough |

## Gotchas

- Chunk size matters — too small loses context, too large dilutes relevance
- Always include source attribution in responses for client trust
- Re-run ingestion when source documents change
- Monitor similarity scores — if consistently low, review chunking strategy
- Test with questions that AREN'T in the knowledge base to verify "I don't know" handling
