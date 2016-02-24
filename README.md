## Cell-based VLSI layout compaction ##
- - -
## Ameer Abdelhadi; ameer.abdelhadi@gmail.com ##
- - -

<BR><BR>

## SYNOPSIS: ##

  Cell-based VLSI layout compaction algorithm based on a modified Segments tree data structure; programmed in Perl script.
  **LICENSE:** BSD 3-Clause ("BSD New" or "BSD Simplified") license.
## USAGE: ##

```
  cellCompaction.pl -iter <compaction iterations> -Xshrf <horizontal shrinking factor> -Yshrf <Vertical shrinking factor> -input <CIF input file> -comp <CIF output file>
```

## PARAMETERS: ##
```
  -iter : Number of compaction iterations (vertical then horizontal X-Y). [default is 10]
  -Xshrf: Boundary polygons horizontal shrink factor. [default is 0, no shrinking]
  -Yshrf: Boundary polygons vertical shrink factor. [default is 0, no shrinking]  
  -input: input CIF file, contains boundary polygons.
  -comp : Generated output CIF file, compacted boundary polygons.
  -ps   : Plots the segments tree graph as a PostScript file.
  >> (-input) and (-comp) are mandatory
```

## EXAMPLE: ##
```
  cellCompaction.pl -iter 20 -Xshrf 0.3 -Yshrf 0.3 -input cells.cif -comp compacted.cif -ps segmentsTree.ps
```

## SUPPORT: ##
  Ameer Abdelhadi
  ameer.abdelhadi@gmail.com
