# Running the project

```bash
anvil
```


In a separate terminal, run:

```bash
forge build
```

```bash
forge create contracts/Voting.sol:Voting \
  --rpc-url http://127.0.0.1:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast
```

You should get an output in the following format:

```
Deployer: 0xF39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Deployed to: <DEPLOYED_CONTRACT_ADDRESS>
Transaction hash: 0x...
```

Verify that the contract is properly deployed

```bash 
cast call <DEPLOYED_CONTRACT_ADDRESS> "owner()(address)" \
  --rpc-url http://127.0.0.1:8545
```
This should return the address of the owner.


```bash
cd voting-backend
node index.js
```

## Add candidate

using anvil
```bash
cast send <DEPLOYED_CONTRACT_ADDRESS> "addCandidate(string)" "Alice" \
  --rpc-url http://127.0.0.1:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

  using POST

  ```bash
  curl -X POST http://localhost:3000/candidates \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Bob",
    "isOwner": true
  }'
```
### voting

using anvil

```bash
cast send <DEPLOYED_CONTRACT_ADDRESS> "vote(uint256)" 1 \
  --rpc-url http://127.0.0.1:8545 \
  --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
```


using POST
```bash
curl -X POST http://localhost:3000/vote \
  -H "Content-Type: application/json" \
  -d '{
    "account":"0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"
    "candidateIndex": 0
  }'
```

### get candidates
using anvil
```bash
cast call <CONTRACT_ADDRESS> "getCandidates()((string ,uint256 )[])" \
  --rpc-url http://127.0.0.1:8545

```

using GET
```bash
curl http://localhost:3000/candidates
```

### get winner

using Anvil
```bash
cast call <DEPLOYED_CONTRACT_ADDRESS> "getWinner()(string)" \
  --rpc-url http://127.0.0.1:8545
```


using POST

```bash
curl http://localhost:3000/winner
```