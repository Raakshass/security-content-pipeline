# Reentrancy in `withdraw()`
**Status:** Fixed in commit <hash> ✅

**Severity:** High  
**Source:** Slither run 2025-07-01  

## Slither excerpt
Reentrancy in VulnBank.withdraw() (VulnBank.sol#11-17):
External calls:
- (ok,None) = msg.sender.call{value: bal}() (VulnBank.sol#14)
State variables written after the call(s):
- balances[msg.sender] = 0 (VulnBank.sol#16)
## Next actions
- [ ] Write a Foundry test that shows the exploit  
- [ ] Estimate potential loss (all user balances)  
- [ ] Suggest fix (`checks-effects-interactions` or ReentrancyGuard)
  
