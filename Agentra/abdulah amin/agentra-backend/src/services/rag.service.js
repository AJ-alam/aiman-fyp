// services/rag.service.js
const { HuggingFaceTransformersEmbeddings } = require("@langchain/community/embeddings/hf_transformers");
const { MemoryVectorStore } = require("langchain/vectorstores/memory");
const { RecursiveCharacterTextSplitter } = require("langchain/text_splitter");
const { Document } = require("langchain/document");
const XLSX = require("xlsx");
const path = require("path");
const fs = require("fs");

let vectorStore = null;

function inferType(filename) {
  const n = filename.toLowerCase();
  if (n.includes("hotel")) return "hotel";
  if (n.includes("park")) return "parking";
  if (n.includes("histor") || n.includes("place")) return "historical_place";
  if (n.includes("food") || n.includes("restaurant")) return "food";
  return "general";
}

function loadExcelDocuments() {
  const dataDir = path.join(__dirname, "../data");
  const documents = [];

  if (!fs.existsSync(dataDir)) {
    console.warn("⚠️  No /data folder found.");
    return documents;
  }

  const files = fs.readdirSync(dataDir).filter((f) => 
    f.endsWith(".xlsx") || f.endsWith(".xls") || f.endsWith(".csv")
  );

  if (files.length === 0) {
    console.warn("⚠️  No data files found in /data folder.");
    return documents;
  }

  for (const file of files) {
    const filePath = path.join(dataDir, file);
    let rows = [];

    if (file.endsWith(".csv")) {
      // Read CSV using XLSX (it handles CSV too)
      const workbook = XLSX.readFile(filePath, { type: "file" });
      const sheetName = workbook.SheetNames[0];
      rows = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName]);
    } else {
      // Read Excel
      const workbook = XLSX.readFile(filePath);
      for (const sheetName of workbook.SheetNames) {
        const sheetRows = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName]);
        rows = rows.concat(sheetRows.map(row => ({ ...row, _sheet: sheetName })));
      }
    }

    for (const row of rows) {
      const content = Object.entries(row)
        .filter(([key]) => key !== "_sheet")
        .map(([key, value]) => `${key}: ${value}`)
        .join("\n");

      documents.push(
        new Document({
          pageContent: content,
          metadata: {
            source: file,
            type: inferType(file),
          },
        })
      );
    }
    console.log(`📄 Loaded: ${file}`);
  }

  return documents;
}
  

async function initVectorStore() {
  if (vectorStore) return vectorStore;

  console.log("🔧 Building in-memory vector store from Excel files...");

const embeddings = new HuggingFaceTransformersEmbeddings({
  model: "Xenova/all-MiniLM-L6-v2",
});

  const docs = loadExcelDocuments();

  if (docs.length === 0) {
    vectorStore = await MemoryVectorStore.fromTexts(
      ["Agentra chatbot ready. Add Excel files to /data folder."],
      [{ source: "placeholder" }],
      embeddings
    );
    console.log("⚠️  Vector store created with placeholder (no Excel data).");
    return vectorStore;
  }

  const splitter = new RecursiveCharacterTextSplitter({
    chunkSize: 500,
    chunkOverlap: 50,
  });
  const splitDocs = await splitter.splitDocuments(docs);

  vectorStore = await MemoryVectorStore.fromDocuments(splitDocs, embeddings);
  console.log(`✅ Vector store ready — ${splitDocs.length} chunks indexed.`);
  return vectorStore;
}

async function retrieveExcelContext(query, k = 5) {
  const store = await initVectorStore();
  const results = await store.similaritySearch(query, k);
  return results.map((r) => r.pageContent).join("\n\n---\n\n");
}

module.exports = { initVectorStore, retrieveExcelContext };
