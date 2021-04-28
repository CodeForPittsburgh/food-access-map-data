# PFPC Food Map Rules

## Establishment Types

- farmer&#39;s market
- fresh access
- supermarket
- convenience store
- summer food site
- food bank site
- Grow PGH garden

## Establishment Labels (to use in map)

- FMNP
- SNAP
- WIC
- food\_bucks
- fresh\_produce
- free\_distribution
- open\_to\_spec\_group

## Global Rules

- If type = farmer&#39;s market, then FMNP, fresh\_produce = 1
- If type = Supermarket, then fresh\_produce = 1
- If data source = Just Harvest Fresh Corner Stores.xlsx, then fresh\_produce = 1
- If data source = Just Harvest - Fresh Access Markets.xlsx, then food\_bucks, fresh\_produce = 1
- If data source = PA.xlsx (USDA SNAP source), then SNAP = 1
- If food\_bucks = 1, then SNAP = 1
- If data source = Allegheny\_County\_WIC\_Vendor\_Locations.xlsx (WPRDC WIC source), then WIC = 1
- If data source = GPCFB - Green Grocer.xlsx, then FMNP = 1
- If data source = Greater Pittsburgh Community Food Bank, then free\_distribution = 1
- If free\_distribution = 1, then SNAP, WIC, FMNP, food\_bucks = 0 (you can&#39;t pay for free food!)
- If type = summer food site, then open\_to\_spec\_group = &#39;children and teens 18 and younger&#39; (if type = food bank site, other entries for open\_to\_spec\_group exist)

## Rules by Source

### Additional Food Bucks Sites

- No entry-by-entry rules
- if &quot;farmers market&quot; in name, then type = farmer&#39;s market, else type = supermarket
  - type = [blank] - no consistent type
- SNAP = 1
- WIC = NA
- If type = farmers market, then FMNP = 1
- food\_bucks = 1
- free\_distribution = 0

### FMNP

- type = farmer&#39;s market
- FMNP = 1
- fresh\_produce = 1
- pen\_to\_spec\_group = 0
- free\_distribution = 0
- SNAP = NA
- food\_bucks = NA
- WIC = NA

### Fresh Access Markets

- No entry-by-entry rules
- type = fresh access
- SNAP = 1
- WIC = 1
- FMNP = 1
- fresh\_produce = 1
- food\_bucks = 1
- free\_distribution = 0

### Fresh Corners

- If &#39;Participates in Food Bucks SNAP Incentive Program&#39; == &#39;yes&#39;, food\_bucks = 1. Otherwise, food\_bucks = 0.
- If &#39;Participates in Food Bucks SNAP Incentive Program&#39; == &#39;yes&#39;, SNAP = 1
- type = convenience store
- FMNP = 0
- fresh\_produce = 1
- free\_distribution = 0

### Greater Pittsburgh Community Food Bank

- If PublicNotes = &quot;grocery&quot;, &quot;groceries&quot;, &quot;fresh&quot;, then fresh\_produce = 1. Otherwise, fresh\_produce = 0.
- SNAP = 0
- WIC = 0
- FMNP = 0
- food\_bucks = 0
- free\_distribution = 1

### Summer Meal Sites

- No entry-by-entry rules
- SNAP = 0
- WIC = 0
- FMNP = 0
- food\_bucks = 0
- free\_distribution = 1
- open\_to\_spec\_group = &#39;children and teens 18 and younger&#39;

### SNAP

- Yes entry-by-entry rules (depends on type, many of which are missing/could be text processed)
- SNAP = 1
- WIC = NA
- FMNP =NA
- If type == &quot;supermarket | farmers market&quot;, then fresh\_produce = 1
- food\_bucks = NA
- free\_distribution = 0
- open\_to\_spec\_group = 0

### Green Grocer (now falls under FMNP original source, but name contains &quot;green grocer&quot;

- Yes entry-by-entry rules (depends on city)
- type = farmer&#39;s market
- SNAP = 1
- WIC = 0
- FMNP = 1
- fresh\_produce = 1
- food\_bucks = 1
- free\_distribution = 0
- open\_to\_spec\_group = 0

### AGH WIC

- Yes entry-by-entry rules (depends on type)
- SNAP = NA
- WIC = 1
- FMNP = NA
- If type == &quot;supermarket | farmers market&quot;, fresh\_produce = 1
- food\_bucks = NA
- free\_distribution = 0
- open\_to\_spec\_group = 0

### Grow PGH Garden

- type = &quot;Grow PGH Garden&quot;
- SNAP = 1
- WIC = 0
- FMNP = 1
- fresh\_produce = 1
- food\_bucks = 1
- free\_distribution = 0
- open\_to\_spec\_group = 0

## ARCHIVED sources

### Allegheny County Farmers Markets

- If &quot;fresh access&quot; in name and/or affiliations, then type = fresh access, else type = farmers market
- If type == fresh access, then SNAP, food\_bucks, fresh produce = 1
- SNAP = 1
- WIC = 1
- FMNP = 1
- fresh\_produce = 1
- food\_bucks = 1
- free\_distribution = 0