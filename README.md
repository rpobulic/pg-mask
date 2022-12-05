# pg-mask
Simple data masking for PostgreSQL
## Installation
Just clone the github repository to any *path*, both on source and target Linux (or any OS with bash) systems.
## Usage
Columns with sensitive information which have to be obfuscated before sending the dump to an external party for development/testing/tuning, can be marked by entering a special expression into the database column description. There are three types of these expressions:
1. "msk"det" for deterministic hashing (double quotes are part of the expression), should be used when the same original value has to have the same obfuscated value
2. "msk"rand" for random obfuscation
3. "msk"*any valid SQL expression for a select from the corresponding table, returning the same type and within the maximum length of the column*"

You can easily edit the column descriptions using pgadmin4 or DBeaver.

After marking the sensitive columns, you can export all data of *owner*:

*path*/pg-mask/bin/mask.sh *dbname* *ownername*

This will create three files in the current directory:
- pre_data.sql
- masked_data.sql
- post_data.sql

These files should be copied to the target system. To import them into the target database, run this in the target directory:

*path*/pg-mask/bin/import_masked.sh *dbname* *ownername*
