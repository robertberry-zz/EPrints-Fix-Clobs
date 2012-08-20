# EPrints Fix Clobs

The latest version of EPrints (3.3.10) has a bug with the database layer for
Oracle databases, insofar as any tables with the __ORDERVALUES_EN suffix
contain CLOB fields. These fields are used throughout EPrints for ordering,
but Oracle is not able to order by CLOB fields, so these should be
VARCHAR2(1000)s (as they were in older versions of EPrints). This script fixes
the tables.
