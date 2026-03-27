# A Generalised Theory of Balance Algebras

## 1. Motivation

In the base domain theory, a balance is defined as the sum of transaction contributions:

$$B_F(p) = \sum_{\substack{e \in E,\ e \in D,\ Scope_R(e)=1,\\ BalPath_F(e) = p}} Val(e).$$

Summation is a specific choice of aggregation function. From this choice follows a property that the base theory calls "additivity":

$$B^{E_1 \cup E_2}(p) = B^{E_1}(p) + B^{E_2}(p).$$

However, additivity is not an axiom of the model. It is a **consequence** of choosing summation as the aggregation function. A different function gives rise to a different relationship between parts and whole.

The purpose of this document is to define the **class of admissible aggregation functions** (balance algebras), to show that each such function induces its own parent–children relationship rule, and to determine which properties of the domain model are truly fundamental and which are merely particular consequences of the choice of summation.

---

## 2. The Central Observation

Consider a tree or roll-up in which a coarse key $k$ is expanded into detail keys $k_1, \dots, k_m$.

In the base theory, the parent value is determined via its children:

$$B(k) = \sum_{i=1}^{m} B(k_i).$$

This is a specific relationship rule: **the value of the whole equals the sum of the parts**.

If, however, the aggregation function is the arithmetic mean, the relationship rule differs:

$$B(k) = \frac{\sum_i n_i \cdot B(k_i)}{\sum_i n_i},$$

where $n_i$ is the number of transactions in the $i$-th child. The value of the whole is the **weighted average** of its parts, not their sum.

If the function is the maximum:

$$B(k) = \max_i B(k_i).$$

The value of the whole is the **maximum** over the parts.

Thus, **the choice of aggregation function determines the relationship rule between parent and children**. Additivity is the relationship rule induced by summation. Other functions yield other rules.

The question is: what do these rules have in common? What structure unifies summation, the mean, the maximum, and other admissible functions?

---

## 3. Balance Algebra

### 3.1. Definition

A balance algebra is a tuple

$$\mathcal A = (S,\ s_0,\ \oplus,\ inc,\ val),$$

where:

- $S$ is the space of internal states;
- $s_0 \in S$ is the initial state (the empty aggregate);
- $\oplus : S \times S \to S$ is the merge operation on two states;
- $inc : S \times \mathbb R \to S$ is the operation that incorporates a new transaction value into a state;
- $val : S \to \mathbb R$ is the extraction function that produces the final value from a state.

### 3.2. Axioms

The merge operation $\oplus$ satisfies:

1. **Associativity:** $(s_1 \oplus s_2) \oplus s_3 = s_1 \oplus (s_2 \oplus s_3)$
2. **Commutativity:** $s_1 \oplus s_2 = s_2 \oplus s_1$
3. **Identity element:** $s_0 \oplus s = s$

Incorporation is compatible with merging:

4. **Compatibility:** $inc(s, x) = s \oplus inc(s_0, x)$

### 3.3. Interpretation

$(S, \oplus, s_0)$ is a commutative monoid. This is the fundamental structure that unifies all admissible aggregation functions.

The meaning of the axioms is as follows:

- Associativity and commutativity guarantee that **the order of transaction processing does not affect the result**;
- The identity element guarantees that **the empty set of transactions yields a well-defined initial state**;
- Compatibility guarantees that **incorporating a transaction is equivalent to merging with a singleton state**.

### 3.4. Two Levels: State and Value

The key distinction of the generalised theory from the base theory is as follows:

- **State** $\sigma \in S$ is what is stored. For summation this is a single number; for the mean it is a pair (sum, count); for variance it is a triple.
- **Value** $val(\sigma) \in \mathbb R$ is what is read. For summation $val = id$; for the mean $val((s, n)) = s/n$.

Merging operates at the level of states. Value extraction is the final step, applied at read time.

---

## 4. The Parent–Children Relationship Rule

### 4.1. General Formulation

For any balance algebra, the relationship rule between a parent key $k$ and its children $k_1, \dots, k_m$ is defined through the merging of states:

$$\sigma(k) = \sigma(k_1) \oplus \sigma(k_2) \oplus \dots \oplus \sigma(k_m).$$

The resulting value of the parent:

$$B(k) = val(\sigma(k)) = val\left(\bigoplus_{i=1}^{m} \sigma(k_i)\right).$$

This is the **generalised balance equation**. It asserts: the state of the whole equals the merge of the states of the parts.

### 4.2. Special Cases

**Summation.** $S = \mathbb R$, $\oplus = +$, $val = id$.

$$B(k) = val\left(\sum_i \sigma(k_i)\right) = \sum_i B(k_i).$$

Relationship rule: the parent value equals the sum of the children's values. This is precisely the "additivity" of the base theory.

**Mean.** $S = \mathbb R \times \mathbb N$, $\oplus((s_1,n_1),(s_2,n_2)) = (s_1+s_2, n_1+n_2)$, $val((s,n)) = s/n$.

$$\sigma(k) = \left(\sum_i s_i,\ \sum_i n_i\right)$$

$$B(k) = \frac{\sum_i s_i}{\sum_i n_i} = \frac{\sum_i n_i \cdot B(k_i)}{\sum_i n_i}.$$

Relationship rule: the parent value is the weighted average of the children, with weights equal to the transaction counts.

**Maximum.** $S = \mathbb R \cup \{-\infty\}$, $\oplus = \max$, $val = id$.

$$B(k) = \max_i B(k_i).$$

Relationship rule: the parent value is the maximum over the children.

### 4.3. Why the Rule Follows from the Choice of Algebra

The relationship rule is not specified independently. It is **derived** from the operation $\oplus$ and the function $val$. Knowing the algebra, one automatically knows:

- how states aggregate from bottom to top;
- how the parent's final value is expressed in terms of the children's values (or states);
- which identities hold.

Additivity is the identity $val(\sigma_1 \oplus \sigma_2) = val(\sigma_1) + val(\sigma_2)$, which is true for SUM and false for AVG.

---

## 5. Mergeability as a Fundamental Property

### 5.1. Definition

Mergeability is a property shared by **all** balance algebras:

$$\sigma^{E_1 \cup E_2}(p) = \sigma^{E_1}(p) \oplus \sigma^{E_2}(p).$$

The state constructed from the union of transaction sets equals the merge of the states constructed from each set individually.

### 5.2. Mergeability vs. Additivity

Additivity is a special case of mergeability for the SUM algebra:

$$B^{E_1 \cup E_2}(p) = B^{E_1}(p) + B^{E_2}(p).$$

This holds because for SUM, $val = id$ and $\oplus = +$, so mergeability at the state level **coincides** with additivity at the value level.

For AVG, mergeability at the state level is preserved:

$$(s_1, n_1) \oplus (s_2, n_2) = (s_1 + s_2, n_1 + n_2),$$

but additivity at the value level **does not** hold:

$$\frac{s_1 + s_2}{n_1 + n_2} \ne \frac{s_1}{n_1} + \frac{s_2}{n_2}.$$

### 5.3. What Mergeability Provides

Mergeability guarantees:

- **Parallel processing:** transactions can be partitioned, processed independently, and the resulting states merged;
- **Incremental updates:** a new transaction amounts to merging the current state with a singleton state;
- **Correct roll-up:** the state of a coarse key equals the merge of the states of its detail keys;
- **Failure recovery:** states can be recomputed from any subset and merged.

This is a **fundamental** property of the model. Additivity is merely a particular manifestation of it.

---

## 6. Transparent and Opaque Algebras

### 6.1. Definition

A balance algebra is called **transparent** if $val$ is the identity, i.e., $S = \mathbb R$ and $val(s) = s$.

A balance algebra is called **opaque** if $val$ is a non-trivial function, i.e., the state and the final value differ.

### 6.2. The Key Distinction

For transparent algebras, the parent–children relationship rule is expressed **in terms of final values**:

$$B(k) = B(k_1) \oplus B(k_2) \oplus \dots \oplus B(k_m).$$

For opaque algebras, the relationship rule operates only **at the state level**. The parent value cannot be computed from the children's values alone — their states are required.

### 6.3. Examples

| Algebra | Transparency | $S$ | $val$ | Relationship rule at the value level |
|---|---|---|---|---|
| SUM | transparent | $\mathbb R$ | $id$ | $B(k) = \sum_i B(k_i)$ |
| COUNT | transparent | $\mathbb N$ | $id$ | $B(k) = \sum_i B(k_i)$ |
| MIN | transparent | $\mathbb R \cup \{+\infty\}$ | $id$ | $B(k) = \min_i B(k_i)$ |
| MAX | transparent | $\mathbb R \cup \{-\infty\}$ | $id$ | $B(k) = \max_i B(k_i)$ |
| AVG | opaque | $\mathbb R \times \mathbb N$ | $s/n$ | not possible without knowing $(s_i, n_i)$ |
| WEIGHTED AVG | opaque | $\mathbb R \times \mathbb R$ | $s/w$ | not possible without knowing $(s_i, w_i)$ |
| VAR | opaque | $\mathbb R \times \mathbb R \times \mathbb N$ | $q/n - (s/n)^2$ | not possible without knowing $(s_i, q_i, n_i)$ |

### 6.4. Business Interpretation

For transparent algebras, a client can operate solely with final values. Knowing the GMV by country, one can compute the GMV by region — simply by summing.

For opaque algebras, the client requires access to the states in order to aggregate correctly. Knowing the average order value by country, one cannot compute the average order value by region — the sums and counts are needed.

---

## 7. Concrete Algebras

### 7.1. SUM

$$\mathcal A_{sum} = (\mathbb R,\ 0,\ +,\ inc,\ id)$$

- $inc(s, x) = s + x$
- Relationship rule: $B(k) = \sum_i B(k_i)$

The fundamental algebra of double-entry bookkeeping. The balance of an account is the sum of all postings.

### 7.2. COUNT

$$\mathcal A_{count} = (\mathbb N,\ 0,\ +,\ inc,\ id)$$

- $inc(s, x) = s + 1$ (the transaction value is ignored)
- Relationship rule: $B(k) = \sum_i B(k_i)$

Number of orders, number of transactions. Formally, SUM and COUNT induce the same relationship rule (summation) but differ in their $inc$ functions.

### 7.3. AVG

$$\mathcal A_{avg} = (\mathbb R \times \mathbb N,\ (0,0),\ \oplus,\ inc,\ val)$$

- $\oplus((s_1,n_1),(s_2,n_2)) = (s_1+s_2,\ n_1+n_2)$
- $inc((s,n), x) = (s+x,\ n+1)$
- $val((s,n)) = s/n$

Relationship rule:

$$B(k) = \frac{\sum_i n_i \cdot B(k_i)}{\sum_i n_i}$$

Average order value, average order GMV, average ride cost.

### 7.4. Weighted Average (WEIGHTED AVG)

$$\mathcal A_{wavg} = (\mathbb R \times \mathbb R,\ (0,0),\ \oplus,\ inc,\ val)$$

- $\oplus((s_1,w_1),(s_2,w_2)) = (s_1+s_2,\ w_1+w_2)$
- $inc((s,w_{total}), (x, w)) = (s + w \cdot x,\ w_{total} + w)$
- $val((s,w_{total})) = s / w_{total}$

Relationship rule:

$$B(k) = \frac{\sum_i w_i \cdot B(k_i)}{\sum_i w_i}$$

Volume-weighted exchange rate, value-weighted portfolio price.

### 7.5. MIN / MAX

$$\mathcal A_{min} = (\mathbb R \cup \{+\infty\},\ +\infty,\ \min,\ inc,\ id)$$

$$\mathcal A_{max} = (\mathbb R \cup \{-\infty\},\ -\infty,\ \max,\ inc,\ id)$$

- $inc(s, x) = \min(s, x)$ or $\max(s, x)$
- Relationship rule: $B(k) = \min_i B(k_i)$ or $B(k) = \max_i B(k_i)$

Extreme values for risk monitoring.

### 7.6. Variance (VAR)

$$\mathcal A_{var} = (\mathbb R \times \mathbb R \times \mathbb N,\ (0,0,0),\ \oplus,\ inc,\ val)$$

- State: $(sum, sum\_sq, count)$
- $\oplus((s_1,q_1,n_1),(s_2,q_2,n_2)) = (s_1+s_2,\ q_1+q_2,\ n_1+n_2)$
- $inc((s,q,n), x) = (s+x,\ q+x^2,\ n+1)$
- $val((s,q,n)) = q/n - (s/n)^2$

A three-dimensional state. Transaction volatility, order value dispersion.

---

## 8. The Generalised Balance Family

### 8.1. Definition

In the generalised theory, a balance family is:

$$F = (D, R, M, \Theta, \mathcal A).$$

Five components:

- $D$ — domain (additivity class, or more precisely, mergeability class);
- $R$ — rule (scope);
- $M$ — materialisation (groupBy);
- $\Theta$ — temporal specification;
- $\mathcal A$ — balance algebra.

### 8.2. Balance Row

A balance row stores a state $\sigma_F(p) \in S$, not a number.

The final value:

$$B_F(p) = val(\sigma_F(p)).$$

### 8.3. Transaction Write

Upon arrival of a transaction $e$ that maps to path $p$:

$$\sigma_F(p) \leftarrow inc(\sigma_F(p),\ Val(e)).$$

Complexity: $O(k)$ in the number of active families — the same as in the base theory.

### 8.4. Read

$$Read(p) = val(\sigma_F(p)).$$

Complexity: $O(1)$ — the same as in the base theory.

---

## 9. Roll-Up in the Generalised Model

### 9.1. Formulation

Roll-up is defined at the state level:

$$\sigma_{coarse}(k) = \bigoplus_{k' \to k} \sigma_{fine}(k').$$

Value:

$$B_{coarse}(k) = val\left(\bigoplus_{k' \to k} \sigma_{fine}(k')\right).$$

### 9.2. Example: Roll-Up of Average Order Value

Detail rows:

| Key | State (sum, count) | Value (avg) |
|---|---|---|
| (EE, Food) | (1 000, 50) | 20.00 |
| (EE, Grocery) | (600, 20) | 30.00 |

Naïve roll-up over values: $(20 + 30) / 2 = 25$ — **incorrect**.

Correct roll-up over states:

$$\sigma(EE) = (1000, 50) \oplus (600, 20) = (1600, 70)$$

$$B(EE) = val((1600, 70)) = 1600 / 70 \approx 22.86$$

### 9.3. Example: Roll-Up of Maximum

| Key | Value (max) |
|---|---|
| (EE, Food) | 12 000 |
| (EE, Grocery) | 8 000 |

$$B(EE) = \max(12\,000, 8\,000) = 12\,000$$

For transparent algebras, roll-up over values is correct. For opaque algebras, only roll-up over states is valid.

---

## 10. Conversion in the Generalised Model

### 10.1. Conversion Within a Single Algebra

If both families use the same algebra, conversion works as in the base theory:

$$\sigma_{target}(p_B) = \bigoplus_{target} \{\Gamma_S(\sigma_{source}(p_A)) : \Psi(p_A) = p_B\},$$

where $\Gamma_S : S \to S$ is the state transformation.

### 10.2. Conversion Between Algebras

Conversion $\mathcal A_1 \to \mathcal A_2$ requires a mapping $\Gamma_S : S_1 \to S_2$ that is compatible with merging:

$$\Gamma_S(s_1 \oplus_1 s_2) = \Gamma_S(s_1) \oplus_2 \Gamma_S(s_2).$$

Such a mapping is a monoid homomorphism.

### 10.3. The Information Constraint

Conversion is possible only if the source state contains sufficient information to construct the target state.

Admissible directions:

- AVG → SUM: $\Gamma_S((s, n)) = s$ — the sum can be extracted from the mean's state.
- AVG → COUNT: $\Gamma_S((s, n)) = n$ — the count can be extracted from the mean's state.
- VAR → AVG: $\Gamma_S((s, q, n)) = (s, n)$ — the mean can be extracted from the variance state.

Inadmissible directions:

- SUM → AVG: the count cannot be recovered from the sum alone.
- COUNT → SUM: the sum cannot be recovered from the count alone.
- MAX → SUM: the sum cannot be recovered from the maximum alone.

### Business Interpretation

If the system stores the average order value (state = sum + count), it is possible to derive the GMV (sum) and the order count from it. However, if only the GMV (a single number) is stored, the average order value cannot be recovered — the count information has been lost.

This is a fundamental principle: **a richer state subsumes a poorer one, but not vice versa**.

---

## 11. Derived Composition in the Generalised Model

### 11.1. Formulation

Derived composition operates on **extracted values**:

$$B_{F_*}(p) = \Phi(val_1(\sigma_{F_1}(p)), \dots, val_n(\sigma_{F_n}(p))).$$

### 11.2. Example: Profit = Income − Expense

Both families use SUM. $val = id$.

$$B_{profit}(p) = B_{income}(p) - B_{expense}(p).$$

### 11.3. Example: Revenue per Order = GMV / Order Count

The GMV family uses SUM. The order count family uses COUNT.

$$B_{rpo}(p) = \frac{val_{sum}(\sigma_{GMV}(p))}{val_{count}(\sigma_{orders}(p))}.$$

The result is a number that does not possess its own algebra. A derived family is a computed object — it is calculated, not accumulated.

### 11.4. Invariant: Multiple Algebras Within a Single Domain

If SUM, COUNT, and AVG coexist within a single domain with identical scope and groupBy, the following identity holds among them:

$$val_{sum}(\sigma_{F_{sum}}(p)) = val_{avg}(\sigma_{F_{avg}}(p)) \times val_{count}(\sigma_{F_{count}}(p)),$$

that is: GMV = average order value × order count.

This is not a coincidence but a consequence of the fact that all three families operate on the same transaction stream.

---

## 12. Idempotency

### 12.1. Definition

An algebra is called **idempotent** if:

$$s \oplus s = s \quad \forall s \in S.$$

### 12.2. Examples

- MIN, MAX are idempotent: $\min(x, x) = x$, $\max(x, x) = x$.
- SUM, COUNT, AVG are non-idempotent: $s + s = 2s \ne s$.

### 12.3. Practical Significance

Idempotent algebras are safe under transaction duplication: reprocessing the same transaction does not alter the result. Non-idempotent algebras require exactly-once guarantees.

This is important in the design of the write path: if the system admits at-least-once delivery of transactions, idempotent algebras are correct without deduplication.

---

## 13. Temporal Compatibility

The temporal extension from balance-domains-temporal is fully compatible with generalised algebras.

For a family $F = (D, R, M, turn(g), \mathcal A)$, the write of a transaction $e$ with timestamp $\tau(e)$ updates:

$$\sigma_F(k_M, \omega) \leftarrow inc(\sigma_F(k_M, \omega),\ Val(e)),$$

where $\omega = \pi_g(\tau(e))$.

Temporal roll-up:

$$\sigma_{month}(k_M, m) = \bigoplus_{d \in days(m)} \sigma_{day}(k_M, d).$$

Accumulated:

$$\sigma_{acc}(k_M) = \bigoplus_{\omega} \sigma_{turn}(k_M, \omega).$$

All formulae are identical to those of the base theory, with $+$ replaced by $\oplus$.

---

## 14. Worked Examples

### 14.1. Average Order Value by Country and Month

Domain: `trx / EUR`. Rule: completed orders. Materialisation: `groupBy = (country)`, $\Theta = turn(month)$, $\mathcal A = \mathcal A_{avg}$.

Transactions for January 2025:

| Date | Country | Amount |
|---|---|---|
| 2025-01-05 | EE | 15 |
| 2025-01-10 | EE | 25 |
| 2025-01-18 | EE | 20 |
| 2025-01-22 | LV | 30 |
| 2025-01-28 | LV | 10 |

Result:

| Country | Month | State (sum, count) | Value (avg) |
|---|---|---|---|
| EE | 2025-01 | (60, 3) | 20.00 |
| LV | 2025-01 | (40, 2) | 20.00 |

Roll-up over all countries:

$$\sigma = (60, 3) \oplus (40, 2) = (100, 5), \quad B = 20.00$$

### 14.2. Volume-Weighted Conversion Rate

Domain: `trx / EUR`. Rule: currency conversions. $\mathcal A = \mathcal A_{wavg}$.

| Date | Source | Rate | Volume |
|---|---|---|---|
| 2025-01-05 | USD | 1.08 | 10 000 |
| 2025-01-12 | USD | 1.10 | 5 000 |
| 2025-01-20 | USD | 1.07 | 15 000 |

$$\sigma = (1.08 \times 10000 + 1.10 \times 5000 + 1.07 \times 15000,\ 30000) = (32\,350,\ 30\,000)$$

$$B = 32\,350 / 30\,000 \approx 1.0783$$

Naïve arithmetic mean: $(1.08 + 1.10 + 1.07)/3 \approx 1.0833$ — incorrect.

### 14.3. Multiple Algebras Within a Single Domain

| Family | Algebra | Business meaning |
|---|---|---|
| $F_1$ | SUM | GMV by country |
| $F_2$ | COUNT | order count |
| $F_3$ | AVG | average order value |
| $F_4$ | MAX | maximum order value |

A single transaction $e$ with $Val(e) = 500$ updates all four:

- $F_1$: $\sigma \leftarrow \sigma + 500$
- $F_2$: $\sigma \leftarrow \sigma + 1$
- $F_3$: $\sigma \leftarrow (s + 500, n + 1)$
- $F_4$: $\sigma \leftarrow \max(\sigma, 500)$

Invariant: $val_{F_1} = val_{F_3} \times val_{F_2}$.

---

## 15. Non-Trivial Balance Algebras

The preceding examples (SUM, AVG, MAX) are intuitively straightforward. However, the class of balance algebras is considerably broader. The following are practical examples, each of which satisfies the axioms of §3.2 and has direct real-world applications.

### 15.1. HyperLogLog (Approximate COUNT DISTINCT)

**Problem:** how many unique users conducted transactions per country per month.

An exact count of distinct values requires storing the set of all identifiers — the state size grows linearly with the number of unique elements. HyperLogLog (HLL) is a probabilistic structure of fixed size (~12 KB) that estimates cardinality with ~2% relative error.

$$\mathcal A_{hll} = (\mathbb Z^m,\ \mathbf{0},\ \oplus,\ inc,\ val)$$

- $S = \mathbb Z^m$ — a vector of $m$ registers (typically $m = 2^{14} = 16384$);
- $s_0 = \mathbf{0}$ — the zero vector;
- $\oplus(\mathbf{r}_1, \mathbf{r}_2) = (\max(r_{1,1}, r_{2,1}), \dots, \max(r_{1,m}, r_{2,m}))$ — component-wise maximum;
- $inc(\mathbf{r}, x)$: computes the hash of $x$, determines the register index, and updates it;
- $val(\mathbf{r})$: the harmonic mean over the registers, adjusted by a bias correction factor.

**Verification of axioms:**

- Associativity: $\max$ is associative.
- Commutativity: $\max$ is commutative.
- Identity element: $\max(\mathbf{0}, \mathbf{r}) = \mathbf{r}$.
- Compatibility: incorporating element $x$ into state $\mathbf{r}$ is equivalent to merging $\mathbf{r}$ with a singleton sketch.

**Roll-up.** Merging HLL sketches across countries yields an HLL sketch for the region that correctly estimates the number of unique users **accounting for intersections** (a user active in both EE and LV is counted only once).

**Classification:** opaque ($val$ is a non-trivial function), idempotent ($\mathbf{r} \oplus \mathbf{r} = \mathbf{r}$, since $\max(r_i, r_i) = r_i$).

### Business Interpretation

Number of unique customers by country, number of unique merchants, number of unique devices. All of these are COUNT DISTINCT, and HLL makes it possible to maintain them as a balance row with fixed-size state and correct roll-up.

---

### 15.2. Histogram (Bucket Distribution)

**Problem:** distribution of order values across ranges (0–10, 10–50, 50–200, 200+) by country and month.

$$\mathcal A_{hist} = (\mathbb N^b,\ \mathbf{0},\ +,\ inc,\ val)$$

- $S = \mathbb N^b$ — a vector of $b$ counters, where $b$ is the number of buckets;
- $s_0 = \mathbf{0}$;
- $\oplus = +$ (component-wise addition);
- $inc(\mathbf{h}, x)$: determines bucket $j$ for value $x$ and increments $h_j$ by 1;
- $val(\mathbf{h})$: depends on the application — may return the entire vector, the mode, an approximate percentile, or a proportion.

**Verification of axioms:** component-wise addition is a commutative monoid with identity element $\mathbf{0}$.

**Roll-up.** The histogram for the Baltic region is the component-wise sum of the per-country histograms. This is an exact operation, not an approximation.

**Classification:** opaque (the state is a vector; the value is a scalar or an interpretation of the vector), non-idempotent.

### Business Interpretation

The distribution of order values reveals not only the average order value but also its structure: what proportion of orders are small, medium, or large. This information cannot be obtained from SUM or AVG — a histogram is required.

Example: the GMV in Estonia is identical in January and February, but in January 80% of orders are small, whereas in February 50% are large. SUM and AVG will not reveal this; a histogram will.

---

### 15.3. T-Digest (Approximate Quantiles)

**Problem:** the 95th percentile of delivery time by country and month.

T-Digest is a structure comprising ~200–300 centroids that approximates the distribution of values.

$$\mathcal A_{tdigest} = (C,\ \emptyset,\ \oplus,\ inc,\ val_q)$$

- $S = C$ — a set of centroids (pairs of mean and weight), bounded in size;
- $s_0 = \emptyset$ — the empty set;
- $\oplus(C_1, C_2)$: union of centroids followed by compression to the maximum permitted size;
- $inc(C, x)$: addition of centroid $(x, 1)$ followed by compression;
- $val_q(C)$: estimation of the $q$-th quantile from the centroids.

**Axioms:** satisfied approximately. Merging is associative and commutative up to the order of compression. In practice, the error is controllable and amounts to ~0.5–1% for extreme quantiles (p95, p99).

**Roll-up.** Merging t-digests across verticals yields a t-digest for the country, from which an approximate percentile is extracted.

**Classification:** opaque, non-idempotent, approximate.

### Business Interpretation

Delivery time SLA: "95% of orders delivered in under 30 minutes." Monitoring this SLA requires the p95, not the mean. T-Digest enables the maintenance of p95 as a balance row with correct roll-up.

---

### 15.4. Bloom Filter (Approximate Membership Testing)

**Problem:** has a given merchant_id appeared among transactions per country per month.

$$\mathcal A_{bloom} = (\{0,1\}^m,\ \mathbf{0},\ \lor,\ inc,\ val)$$

- $S = \{0,1\}^m$ — a bit vector of length $m$;
- $s_0 = \mathbf{0}$;
- $\oplus = \lor$ (bitwise OR);
- $inc(\mathbf{b}, x)$: sets bits $h_1(x), \dots, h_k(x)$ to 1, where $h_i$ are hash functions;
- $val(\mathbf{b})$: membership test — are all bits $h_1(x), \dots, h_k(x)$ set?

**Verification of axioms:** bitwise OR is commutative, associative, with identity element $\mathbf{0}$.

**Roll-up.** OR of bit vectors across countries yields a filter for the region. If a merchant appeared in at least one country, it will be detected in the regional filter.

**Classification:** opaque, idempotent ($\mathbf{b} \lor \mathbf{b} = \mathbf{b}$).

### Business Interpretation

Rapid lookup: did a merchant operate in a given country in a given month? Without scanning all transactions. Useful for compliance, fraud detection, and fast filtering.

---

### 15.5. Covariance and Correlation of Two Measures

**Problem:** correlation between GMV and delivery time by country.

Each transaction carries two measures: $x$ (GMV) and $y$ (delivery time).

$$\mathcal A_{cov} = (\mathbb R^5,\ \mathbf{0},\ +,\ inc,\ val)$$

- State: $(s_x, s_y, s_{xx}, s_{yy}, s_{xy}, n)$ — sums, sums of squares, sum of products, and count;
- $\oplus$ — component-wise addition;
- $inc$: updates all six components;
- $val$: $cov = s_{xy}/n - (s_x/n)(s_y/n)$, $corr = cov / (\sigma_x \cdot \sigma_y)$.

**Verification of axioms:** component-wise addition is a commutative monoid.

**Roll-up.** The covariance for a region is computed correctly through the merger of six-dimensional states.

### Business Interpretation

Is there a relationship between order size and delivery time? Does delivery time increase with GMV? This is an analytical question whose answer can be maintained as a balance row.

---

## 16. What Falls Outside the Class of Balance Algebras

### 16.1. Moving Average

The moving average over the last $k$ transactions requires ordering and a finite window. It is not commutative: the order of transactions is material. It does not form a commutative monoid.

### 16.2. Exact Quantiles and Medians

The exact computation of the median requires storing all values — an infinite-dimensional state. T-Digest and the KLL sketch (§15.3) are approximate balance algebras with controllable error, but exact quantiles are not.

### 16.3. Conditional Aggregates (COUNT IF, SUM IF)

These are not new algebras but rather combinations of a scope and an existing algebra. COUNT IF(country = EE) is simply a family with scope `country = EE` and the COUNT algebra.

---

## 17. Hierarchy of Model Properties

### 17.1. Fundamental Properties (Independent of the Choice of Algebra)

- Domain isolation
- Domain disjointness
- Scope rules
- Materialisation (groupBy)
- Path-space disjointness
- Temporal specification
- Incremental write ($O(k)$)
- Canonical-path read ($O(1)$)
- **Mergeability** ($\sigma^{E_1 \cup E_2} = \sigma^{E_1} \oplus \sigma^{E_2}$)

### 17.2. Algebra-Dependent Properties

- The parent–children relationship rule: determined by $\oplus$ and $val$
- Value-level roll-up: only for transparent algebras
- Additivity: only for SUM
- Idempotency: only for MIN, MAX
- Admissible conversions: determined by the existence of a monoid homomorphism

### 17.3. Summary

The base domain theory is the generalised theory with $\mathcal A = \mathcal A_{sum}$. Additivity is a consequence of choosing summation. The fundamental property is mergeability, not additivity.

