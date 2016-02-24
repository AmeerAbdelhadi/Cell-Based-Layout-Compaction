#!/usr/bin/perl

# SYNOPSIS:
#   Cell-based VLSI layout compaction algorithm based on a modified Segments tree data structure
# USAGE:
#   cellCompaction.pl -iter <compaction iterations> -Xshrf <horizontal shrinking factor>
#   -Yshrf <Vertical shrinking factor> -input <CIF input file> -comp <CIF output file>
# PARAMETERS:
#   -iter : Number of compaction iterations (vertical then horizontal X-Y). [default is 10]
#   -Xshrf: Boundary polygons horizontal shrink factor. [default is 0, no shrinking]
#   -Yshrf: Boundary polygons vertical shrink factor. [default is 0, no shrinking]  
#   -input: input CIF file, contains boundary polygons.
#   -comp : Generated output CIF file, compacted boundary polygons.
#   -ps   : Plots the segments tree graph as a PostScript file.
#   >> (-input) and (-comp) are mandatory
# EXAMPLE:
#   cellCompaction.pl -iter 20 -Xshrf 0.3 -Yshrf 0.3 -input cells.cif -comp compacted.cif -ps segmentsTree.ps
# SUPPORT:
#   Ameer Abdelhadi
#   ameer.abdelhadi@gmail.com

use strict;	  # Install all strictures
use warnings;	  # Show warnings
use FileHandle;   # Use file handle, for dealing with files
use GraphViz;	  # Use graph visualization module
use Getopt::Long; # For command line options (flags)
$|++;		  # Force auto flush of output buffer

require 'cif.pm';
require 'aux.pm';
require 'segmentsTree.pm';
require 'geometry.pm';


##################### Horizontal and Vertical Compaction #####################

my $iter=10;
my $Xshrf=0;
my $Yshrf=0;
my $icif=undef;
my $comp=undef;
my $ps=undef;
my $help=undef;

if ( ! &GetOptions (
	"iterations|iter:i"			=>\$iter,
	"xshrinkf|xshrf|Xshrf:f"	=>\$Xshrf,
	"yshrinkf|yshrf|Yshrf:f"	=>\$Yshrf,
	"input|inp|in:s"			=>\$icif,
	"compacted|compact|comp:s"	=>\$comp,
    "ps:s"						=> \$ps,
	"h|help"					=>\$help
) || $help || (!defined $icif) || (!defined $comp) ) {
print STDOUT <<END_OF_HELP;
USAGE:
  cellCompaction.pl -iter <compaction iterations> -Xshrf <horizontal shrinking factor>
  -Yshrf <Vertical shrinking factor> -input <CIF input file> -comp <CIF output file>
PARAMETERS:
  -iter : Number of compaction iterations (vertical then horizontal X-Y). [default is 10]
  -Xshrf : Boundary polygons horizontal shrink factor. [default is 0, no shrinking]
  -Yshrf : Boundary polygons vertical shrink factor. [default is 0, no shrinking]  
  -input: input CIF file, contains boundary polygons.
  -comp : Generated output CIF file, compacted boundary polygons.
  >> (-input) and (-comp) are mandatory
EXAMPLE:
  cellsCompaction.pl -iter 20 -Xshrf 0.3 -Yshrf 0.3 -input cells.cif -comp compacted.cif -ps segmentsTree.ps
SUPPORT:
  ameer.abdelhadi\@gmail.com
END_OF_HELP
exit;
}


my @cif=cif->semicolon_split(cif->cif2lst($icif));
my @pols=geometry->shrink_boundary_polygon($Xshrf,$Yshrf,cif->bound_cif2pol(@cif));
for (my $i=1;$i<=$iter;$i++) {
	@pols=compactPolygons("horizontal",compactPolygons("vertical",@pols));
}
geometry->polygons2cif($comp,@pols);

##############################################################################

####################################################################
## Synopsis:   Boundary polygons compaction                       ##
## Input:      Direction of compaction "horizontal" or "vertical" ##
##             Polygons data structure                            ##
## Output:     Compacted polygons                                 ##
## Complexity: O(log(n)) n=Polygons number                        ##
####################################################################
sub compactPolygons {
	my ($direction,@pols)=@_;
	## If vertical compaction then reflect input polygons
	if ($direction eq "vertical") {
		@pols=geometry->reflect_boundary_polygons(@pols);
	}	
	my @spols=sort {$a->[1] <=> $b->[1]} @pols;
	my @comp_pols;
	my @cp=geometry->boundary_polygons2cut_points(@spols);
	my $st=segmentsTree->buildSegmentsTree(1,"fillBoundary",0,@cp);

	if ($ps) {segmentsTree->printSegmentsTreeGraph($st,"$ps")}

	foreach my $polp (@spols) {
		my @cpol=@{$polp};
		## get maximum filling oundary on current segment
		my $maxx=segmentsTree->getMaxValue($st,$cpol[2],$cpol[4],"fillBoundary");
		## shift current polygon
		my $dx=$cpol[1]-$maxx;
		for my $i (1,3,5,7) {
			$cpol[$i]-=$dx;
		}
		## update filling boundary
		segmentsTree->updateAttribute($st,$cpol[2],$cpol[4],"fillBoundary",$cpol[5]);		
		push(@comp_pols,\@cpol);
	}
	## If vertical compaction then reflect output polygons
	if ($direction eq "vertical") {
		@comp_pols=geometry->reflect_boundary_polygons(@comp_pols);
	}	
	return @comp_pols;
}
