import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { ethers } from "ethers";
import fs from "fs";
// import accountsMap from "./accounts.json" assert { type: "json" };


dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// --- Setup provider & contract ---
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(process.env.OWNER_PRIVATE_KEY, provider);
const accountsMap = JSON.parse(process.env.ACCOUNTS_JSON || "{}");

const artifact = JSON.parse(fs.readFileSync("../out/Voting.sol/Voting.json", "utf-8"));
const abi = artifact.abi;
const contract = new ethers.Contract(process.env.CONTRACT_ADDRESS, abi, wallet);



// POST /candidates - add candidate (only owner)
app.post("/candidates", async (req, res) => {
    try {
         const { name, isOwner } = req.body;
        if (!name) return res.status(400).json({ error: "Name required" });

 let signer;
    if (isOwner) {
      if (!process.env.OWNER_PRIVATE_KEY) {
        return res.status(500).json({ error: "OWNER_PRIVATE_KEY missing in .env" });
      }
      signer = new ethers.Wallet(process.env.OWNER_PRIVATE_KEY, provider);
    } else {
      return res.status(400).json({ error: "Only owner can add candidates" });
    }

     const contractWithSigner = contract.connect(signer);

        const tx = await contractWithSigner.addCandidate(name);
        await tx.wait();

        res.json({ message: `Candidate ${name} added successfully`, txHash: tx.hash });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// GET /candidates - list all candidates
app.get("/candidates", async (req, res) => {
    try {
        const candidates = await contract.getCandidates();
        const result = candidates.map((c, i) => ({
            index: i,
            name: c.name,
            votes: Number(c.voteCount),
        }));
        res.json(result);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// POST /vote - cast vote
app.post("/vote", async (req, res) => {
    try {
        const { account, candidateIndex } = req.body;

        if (!account || candidateIndex === undefined) {
            return res.status(400).json({ error: "account and candidateIndex required" });
        }

        const privateKey = accountsMap[account];

    if (!privateKey) {
      return res.status(400).json({ error: " No private key found for this account" });
    }

    const signer = new ethers.Wallet(privateKey, provider);

       const contractWithSigner = contract.connect(signer);

        const tx = await contractWithSigner.vote(candidateIndex);
        await tx.wait();

        res.json({ message: `Vote casted by ${account}`, txHash: tx.hash });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// GET /winner - get winner’s name
app.get("/winner", async (req, res) => {
    try {
        const winner = await contract.getWinner();
        res.json({ winner });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// Start server 
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`### Voting backend running on port ${PORT}`));
