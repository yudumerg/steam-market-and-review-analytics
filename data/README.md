# Data

The raw data is not stored in this repository (size and licence).

**Source:** Kaggle – *Gaming Profiles* dataset, Steam subset (`reviews.csv`, `games.csv`).

## Files in this folder

| File | In repo | Description |
|---|---|---|
| `sample_review_ids.csv` | yes | IDs of the 20,000 reviews used in the analysis |
| `labels/dev_labels.csv` | yes | 200 manually labelled reviews, used for error analysis |
| `labels/test_labels.csv` | yes | 150 manually labelled reviews, held-out test set |
| `reviews.csv` | no | Full review table from Kaggle |
| `reviews_sample_20k.csv` | no | The 20,000-review export from BigQuery (optional) |
| `games.csv` | no | Game titles, developers and publishers from Kaggle |

## How to run the notebook

1. Download the dataset from Kaggle.
2. Copy `reviews.csv` and `games.csv` into this folder.
3. Run `notebooks/01_review_complaint_classification.ipynb`.
   The notebook rebuilds the exact 20,000-review sample from `sample_review_ids.csv`.

## Label format

`labels` holds the complaint categories separated by `|` (for example `Bug|Server`).
An empty value means the review contains no complaint.
`pool` shows how the review was sampled: `random`, or `rule_flagged` (flagged by at least one rule version).
