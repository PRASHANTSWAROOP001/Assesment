# Rfam SQL Assessment

This repository contains SQL queries answering a set of questions based on the [Rfam public database](https://docs.rfam.org/en/latest/database.html).

Each answer includes:

1. The SQL query
2. A short explanation of how I arrived at the solution

---

## **a) Tigers in the taxonomy table**

**Question:**
How many types of tigers can be found in the `taxonomy` table of the dataset?
What is the `ncbi_id` of the Sumatran Tiger?

**Answer:**

```sql
-- Count all tiger species in taxonomy
SELECT COUNT(*) AS tigeres_count
FROM taxonomy t
WHERE t.species LIKE '%Panthera tigris%';

-- Find the ncbi_id of the Sumatran tiger
SELECT t.ncbi_id
FROM taxonomy t
WHERE t.species LIKE "%Panthera tigris sumatrae%";
```

**Explanation:**

* I used the **scientific name** `Panthera tigris` in the `species` column to filter tiger entries.
* For the Sumatran tiger, I googled its full name (`Panthera tigris sumatrae`) and used a wildcard search to capture it in the dataset.

---

## **b) Columns that connect tables**

**Question:**
Find all the columns that can be used to connect the tables in the given database.

**Answer:**

```sql
SELECT 
    table_name, 
    column_name, 
    referenced_table_name, 
    referenced_column_name
FROM information_schema.key_column_usage
WHERE table_schema = 'Rfam'
  AND referenced_table_name IS NOT NULL;
```

**Explanation:**

* The `information_schema.key_column_usage` view lists all **foreign key relationships**.
* Running this query shows which columns act as **joins between tables** (e.g., `rfam_acc`, `rfamseq_acc`, `ncbi_id`).

---

## **c) Rice species with longest DNA sequence**

**Question:**
Which type of rice has the longest DNA sequence?

**Answer:**

```sql
SELECT 
    t.species,
    MAX(r.length) AS longest_length
FROM taxonomy t
JOIN rfamseq r 
    ON t.ncbi_id = r.ncbi_id
WHERE t.species LIKE 'Oryza %'
GROUP BY t.species
ORDER BY longest_length DESC
LIMIT 1;
```

**Explanation:**

* First, I identified all **rice species** from the `taxonomy` table using `Oryza %`.
* I then joined with the `rfamseq` table (using `ncbi_id`) to get sequence lengths.
* Finally, I used `MAX(length)` to find the longest DNA sequence.

---

## **d) Paginated family names and DNA sequence lengths**

**Question:**
Paginate a list of the family names and their longest DNA sequence lengths (descending order, >1,000,000). Return the 9th page with 15 results per page.

**Answer:**

```sql
SELECT 
    f.rfam_acc,
    f.rfam_id,
    rs.length
FROM family f
JOIN full_region fr ON f.rfam_acc = fr.rfam_acc
JOIN rfamseq rs ON fr.rfamseq_acc = rs.rfamseq_acc
WHERE rs.length > 1000000
ORDER BY rs.length DESC
LIMIT 15 OFFSET 120;  -- Page 9 → (9-1)*15 = 120
```

**Explanation:**

* `family` and `rfamseq` are not directly connected → needed the **bridge table** `full_region`.
* Filtered DNA sequences where `length > 1,000,000`.
* Applied `ORDER BY` to sort by sequence length.
* Used pagination formula: `OFFSET = (page_number - 1) * page_size`. For page 9 with 15 rows → `OFFSET 120 LIMIT 15`.

---


## **3. Shell Script: Extract Scheme Name & Asset Value**

**Question:**
You are given this URL: `https://portal.amfiindia.com/spages/NAVAll.txt`.
Write a shell script that extracts the *Scheme Name* and *Asset Value* fields only and saves them in a TSV file.

---

### **Solution**

```bash
#!/bin/bash

OUTPUT_FILE='schema.tsv'

curl -s https://portal.amfiindia.com/spages/NAVAll.txt \
 | awk -F ';' 'NF >= 5 {print $4 "\t" $5}' \
 > "$OUTPUT_FILE"

echo "Saved the file inside the address $OUTPUT_FILE"
```

---

### **Explanation**

1. **Understanding the data**

   * The text file from AMFI is `;`-separated.
   * By inspecting it, I saw that:

     * **4th column → Scheme Name**
     * **5th column → Asset Value**

2. **Breaking down the script**

   * `curl -s` → fetches the raw text silently.
   * `awk -F ';'` → sets `;` as the field separator.
   * `NF >= 5` → ensures the line has at least 5 fields (avoids headers/empty lines).
   * `{print $4 "\t" $5}` → extracts Scheme Name & Asset Value, separated by a tab.
   * `> "$OUTPUT_FILE"` → saves output as `schema.tsv`.

3. **Why TSV and not JSON?**

   * TSV is **simpler and more efficient** when storing tabular data like this.
   * Easy to open in **Excel**, **Python pandas**, **R**, etc.
   * JSON is better for **complex/nested data**, but adds unnecessary overhead here since we only have two flat fields.

---

✅ Output file: `schema.tsv` with two tab-separated columns (`Scheme Name`, `Asset Value`).

---

