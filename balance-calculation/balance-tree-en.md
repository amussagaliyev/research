# Theory of Balance Trees and External Projections

## 1. Purpose of the Model

This model describes a system in which there exists **one strictly additive balance tree**, while all projections, marginals, and other aggregates incompatible with strict tree-based additivity are placed in an **external layer of projections**.

The key principle of the model:

> the balance tree is responsible only for strict additivity;
> projections are not part of the tree;
> filters do not affect writes to the tree and are applied only during projection materialization.

This makes it possible to:

- preserve the local and global balance equation within the tree;
- avoid double-counting when storing marginals;
- separate the basic balance layer from the analytical layer.

---

## 2. Space of Dimensions

Let a finite ordered set of dimensions be given:
$$\mathbb D = (d_1, \dots, d_n).$$

For each dimension $d_i$, a set of admissible values is defined:
$$Val(d_i).$$

For each dimension, a special value is introduced:
$$0_i \notin Val(d_i),$$

which is a **special structural value**, not an ordinary dimension value.

The extended set of values for a dimension is then:
$$Val^*(d_i) = Val(d_i) \cup \{0_i\}.$$

### Business interpretation

For example:

- $d_1 =$ `account_type`,
- $d_2 =$ `country`,
- $d_3 =$ `vertical`,

the value `0_2` does not mean that the country "equals zero" and is not a business value of a country.

However, a tree node in which `0_2` appears at the position `country` has a well-defined business meaning:

> the mass at this node has not yet been distributed across countries.

Similarly, if `0_3` appears at the position `vertical`, this means:

> the mass at this node has not yet been distributed across verticals.

Thus:

- $0_i$ is not an ordinary dimension value;
- a node containing $0_i$ has the business meaning of **undistributed mass with respect to dimension $d_i$ and all subsequent dimensions**.

---

## 3. Tree Nodes

The balance tree is constructed as a set of paths of length $n$:
$$\Omega = Val^*(d_1) \times \dots \times Val^*(d_n),$$

but only **canonical tree paths** are considered valid.

A path
$$p = (x_1, \dots, x_n) \in \Omega$$

is called a canonical tree path if there exists an index $r$, $0 \le r \le n$, such that:

- for all $i \le r$: $x_i \in Val(d_i)$,
- for all $i > r$: $x_i = 0_i$.

In other words, after the first unfilled dimension, all subsequent dimensions must also be unfilled.

The set of all canonical tree paths is denoted:
$$T \subseteq \Omega.$$

### Business interpretation

If dimensions are ordered as:

1. `account_type`
2. `country`
3. `vertical`

then valid tree paths are, for example:

- `(income, 0, 0)`
- `(income, EE, 0)`
- `(income, EE, Food)`

But the following path is not valid:

- `(income, 0, Food)`

because you cannot expand `vertical` without expanding `country`.

Each tree node has the following meaning:

- `(income, 0, 0)` — all income mass not yet distributed across countries and verticals;
- `(income, EE, 0)` — all income mass in Estonia not yet distributed across verticals;
- `(income, EE, Food)` — income mass in Estonia for the Food vertical.

That is, a canonical path defines a **sequential opening of mass across dimensions**.

---

## 4. Tree Structure

For any path
$$p = (x_1, \dots, x_n) \in T$$

its depth is defined as the number of initial non-zero components:
$$depth(p) = r.$$

### Parent

If $depth(p) = r > 0$, then the parent of path $p$ is:
$$parent(p) = (x_1, \dots, x_{r-1}, 0_r, \dots, 0_n).$$

### Children

If $depth(p) = r < n$, then for any value
$$v \in Val(d_{r+1})$$

a child of path $p$ is:
$$child(p, v) = (x_1, \dots, x_r, v, 0_{r+2}, \dots, 0_n).$$

### Root

The root of the tree:
$$root = (0_1, \dots, 0_n).$$

### Business interpretation

If the node is:
$$p = (income, EE, 0),$$

then its children are:
$$(income, EE, Food), \quad (income, EE, Grocery), \dots$$

And the parent:
$$(income, 0, 0).$$

From a business perspective:

- the parent node stores mass not yet distributed across the next dimension;
- the child nodes expand this mass across specific values of the next dimension.

For example:

- `(income, 0, 0)` — all income without breakdown by countries;
- `(income, EE, 0)` — the portion of this mass belonging to Estonia;
- `(income, EE, Food)` — the portion of Estonia's mass belonging to the Food vertical.

Thus, the tree is interpreted as a **hierarchy of sequential mass distribution**, and nodes with $0_i$ represent states in which distribution across the next dimension is not yet expanded.

---

## 5. Impulse

An impulse $I$ is defined as a pair:
$$I = (F, \Delta),$$

where:

- $F$ is a complete fixed path of dimension values,
- $\Delta \in \mathbb R$ is a numerical contribution.

A complete path:
$$F = (v_1, \dots, v_n), \qquad v_i \in Val(d_i).$$

### Business interpretation

An impulse is an elementary write event in the system.

For example:
$$F = (expense, EE, Food), \qquad \Delta = 120.$$

This means: a transaction of value 120 has arrived, relating to expenses, Estonia, and the Food vertical.

---

## 6. Canonical Path of an Impulse in the Tree

Each complete path $F = (v_1, \dots, v_n)$ corresponds to a chain of tree nodes:
$$\pi(F) = \{p_0, p_1, \dots, p_n\},$$

where:

$$p_0 = (0_1, \dots, 0_n),$$

$$p_1 = (v_1, 0_2, \dots, 0_n),$$

$$p_2 = (v_1, v_2, 0_3, \dots, 0_n),$$

$$\dots$$

$$p_n = (v_1, \dots, v_n).$$

This is the unique root-to-leaf path in the tree corresponding to impulse $F$.

### Business interpretation

If
$$F = (expense, EE, Food),$$

then the impulse passes through the nodes:

- `(0, 0, 0)`
- `(expense, 0, 0)`
- `(expense, EE, 0)`
- `(expense, EE, Food)`

---

## 7. Balance Function of the Tree

A balance function is defined on the set of tree nodes:
$$B : T \to \mathbb R.$$

Initially:
$$B(p) = 0 \qquad \forall p \in T.$$

When an impulse $I = (F, \Delta)$ is written, **all nodes on the path** $\pi(F)$ are updated:

$$B(p) \leftarrow B(p) + \Delta \qquad \forall p \in \pi(F).$$

### Business interpretation

If the impulse arrives:
$$(expense, EE, Food), \quad \Delta = 120,$$

then 120 is added to:

- the root,
- `(expense, 0, 0)`,
- `(expense, EE, 0)`,
- `(expense, EE, Food)`.

This is the basic logic of the balance tree.

---

## 8. Strict Additivity of the Tree

### 8.1. Local Balance Equation

For any internal node $p \in T$ that has children, the following must hold:
$$B(p) = \sum_{c \in Children(p)} B(c).$$

This is the fundamental balance equation of the tree.

### 8.2. Global Additivity

For any node $p$, its value equals the sum of values of all leaves in its subtree:
$$B(p) = \sum_{\ell \in Leaves(p)} B(\ell).$$

### 8.3. Additivity across Impulses

If $E_1$ and $E_2$ are two sets of impulses, then:
$$B^{E_1 \cup E_2}(p) = B^{E_1}(p) + B^{E_2}(p).$$

### Business interpretation

If node `(expense, EE, 0)` has children:

- `(expense, EE, Food)` = 120
- `(expense, EE, Grocery)` = 30

then:
$$B(expense, EE, 0) = 120 + 30 = 150.$$

This property must always hold. It is precisely what makes the tree a strictly additive balance object.

---

## 9. Why Projections Should Not Be Stored in the Tree

If one attempts to store not only basic paths but also projections like:

- only by `country`,
- only by `vertical`,
- across arbitrary subsets of dimensions,

in the same tree, then the same mass begins to reside in multiple overlapping nodes that can no longer be embedded in a single tree-based balance equation.

This creates the following problems:

1. **double-counting**;
2. **loss of local additivity**;
3. **impossibility of honestly interpreting parent–child relationships**;
4. **mixing of balance and analytical layers**.

### Business Example

If for the impulse
$$(expense, EE, Food), \quad 120$$

one stores simultaneously in the same tree:

- the basic path `(expense, EE, Food)`,
- the projection `(0, EE, Food)`,
- the projection `(expense, 0, Food)`,

then 120 will appear multiple times in overlapping branches, and a unified balance equality cannot be preserved.

---

## 10. Projections as an External Entity

Projections are not part of the balance tree.

A projection is defined as a separate entity built over the existing data of the tree.

Let a subset of dimensions be given:
$$H \subseteq \mathbb D.$$

Then a projection is an aggregate constructed not as a tree node, but as an external function:
$$P_H : \text{tree data} \to \mathbb R.$$

If $k_H$ is a key for the projection on dimensions $H$, then
$$P_H(k_H)$$

is defined as the sum of those leaf-values in the tree that are consistent with this key.

### Business interpretation

If the tree stores only basic balances across the chain:

- `account_type`
- `country`
- `vertical`

then the projection "by countries" is computed as a separate entity:

$$P_{\{country\}}(EE) = \sum_{\text{all leaf-paths with country = EE}} B(\ell).$$

This is not a tree node, but an external analytical balance.

---

## 11. Filter

### 11.1. Filter Is Not Applied to the Tree

The balance tree operates **without a filter**.

Any impulse permissible for the system must be written to the tree along its canonical path.

That is, the basic write to the tree always takes the form:
$$I = (F, \Delta) \mapsto \pi(F).$$

The filter should not restrict this write.

### 11.2. Filter Is Applied Only to Projection Materialization

A filter is an operator that restricts which projections are materialized in the external analytical layer.

A filter can:

- allow materialization of only certain projection keys;
- restrict admissible values of individual dimensions;
- restrict admissible subspaces of analytical projections.

However, the filter does not affect the basic balance layer of the tree.

### Business interpretation

If a company wants to store in analytics only the countries `EE` and `LV`, this does not mean that transactions for `LT` should not be recorded in the basic balance.

The correct scheme:

- all transactions are written to the tree;
- the external projection `by_country` is materialized only for `EE` and `LV`.

---

## 12. Materialization of Projections

Let a projection $P_H$ and a filter $Q$ be given.

The materialized projection is defined only on those keys $k_H$ that satisfy the filter:
$$Q(k_H) = 1.$$

The resulting value of the materialized projection:
$$\widetilde{P}_H(k_H) = \begin{cases} P_H(k_H), & Q(k_H) = 1, \\ \text{not materialized}, & Q(k_H) = 0. \end{cases}$$

### Business interpretation

If there is a projection by countries and a filter:
$$country \in \{EE, LV\},$$

then:

- `P_country(EE)` is materialized,
- `P_country(LV)` is materialized,
- `P_country(LT)` is not materialized,

although transactions for `LT` still remain in the basic tree.

---

## 13. Read Operation

### 13.1. Reading from the Tree

For any node in the tree $p \in T$:
$$ReadTree(p) = B(p).$$

This is reading from the basic balance layer.

### 13.2. Reading from a Projection

For any materialized projection:
$$ReadProjection(H, k_H) = \widetilde{P}_H(k_H).$$

### Business interpretation

The reading system must distinguish between two layers:

1. **tree layer** — reading from the strict balance tree;
2. **projection layer** — reading from analytical projections.

These are two different types of objects, and they cannot be mixed.

---

## 14. Advantages of This Scheme

Separating the tree from the external layer of projections provides:

1. **strict additivity of the tree**;
2. **absence of double-counting within the tree**;
3. **simple parent–child interpretation**;
4. **ability to flexibly filter the analytical layer**;
5. **independence of the basic balance from analytical requirements**.

### Business interpretation

The basic balance layer becomes the source of truth, while the analytical layer is a derived and configurable view.

---

## 15. Limitations of the Model

This model intentionally rejects the idea that all analytical aggregates can be stored in a single balance tree.

It asserts:

- one strictly additive tree;
- all overlapping projections are external.

This makes the theory less universal at the level of "one tree for everything", but much more rigorous and consistent.

---

## 16. Final Scheme

$$\text{Impulse} \to \text{Canonical path in tree} \to \text{Strictly additive balance tree} \to \text{External projections} \to \text{Materialization filter}$$

where:

- the tree is unaware of the filter;
- the filter applies only to external projections;
- projections are not tree nodes;
- the tree preserves the strict balance equation.

---

## 17. Basic Formula of the Model

For the tree:
$$B(p) = \sum_{\substack{I = (F, \Delta)\\ p \in \pi(F)}} \Delta.$$

### Explanation of the Formula

The value of a node $p$ equals the sum of all impulses whose paths pass through that node.

### Business interpretation

If a node corresponds to:

- all expenses,
- or expenses by country,
- or expenses by country and vertical,

then its value is the sum of all transactions that passed through that branch of the tree.

---

## 18. Basic Formula for Projections

For an external projection across dimensions $H$:
$$P_H(k_H) = \sum_{\substack{\ell \in Leaves\\ \ell|_H = k_H}} B(\ell),$$

where $\ell|_H$ is the restriction of the leaf-path to dimensions $H$.

### Business interpretation

If the projection is built by countries, then the value for `EE` is the sum of all leaf-balances in which `country = EE`.

---

## 19. Final Interpretation

A balance tree is not a universal analytical index.
It is a **strictly additive basic layer**.

Projections are not part of the tree.
They are **external analytical entities** built on top of the tree.

A filter is not part of the balance equation.
It is an **operator for materializing external projections**.

Precisely this separation makes it possible simultaneously to:

- preserve the rigorous mathematics of the balance tree;
- obtain the flexibility of the analytical layer.
