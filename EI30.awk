#!/urs/bin/awk
#
#
# This is a awk(*) script that calculates and displays the EI30 erosivity
# index from rainfall gauge records.
# The current version is valid for records with a sampling interval of
#  5 min
#
# ================================================
# José Eugenio López Periago
# Universidade de Vigo
# Faculty of Sciences 32004 Spain
# sáb oct 11 18:26:43 CEST 2014
# ================================================
#
#
# EI calculations, a break between storms is
# defined as 6 h or more with less than 1.3 mm of
# precipitation. Rains less than 13 mm, and separated
# from other storms by 6 or more hours, are moitted
# as insignificant unless the maximum 15 min intensity
# exceeds 24 mm h -1 (Wischmeier and Smith, 1978)

# Note:
# (*)AWK is an interpreted programming language designed for text processing
# and typically used as a data extraction and reporting tool. It is a
# standard feature of most Unix-like operating systems.
# More info at:
# http://en.wikipedia.org/wiki/AWK 
# http://es.wikipedia.org/wiki/AWK  (spanish)
#
#==============================================================================

BEGIN{FS " ";RS "\n"}
{
date[NR]=$1
time[NR]=$2
rain[NR]=$3
}

END{


# Command line assignation of time interval 
# interval = ARGV[1];
interval = 5;

printf "#==========================================================================\n"
printf "# Calculation of EI erosivity indexes from tipping buckett rainfall records\n"
printf "# Using a time lag of %d min\n",interval
printf "===========================================================================\n"
printf "Date\tTime\tEvent_#\tEI5\tEI10\tEI15\tEI30\n"

nepisode=0;

for (I=2;I<=NR;I++)
	{
	sprec =0;
#===================================================
#               Check for a rainfall episode
#===================================================
# EI calculations, a break between storms is
# defined as 6 h or more with less than 1.3 mm of
# precipitation. Rains less than 13 mm, and separated
# from other storms by 6 or more hours, are moitted
# as insignificant unless the maximum 15 min intensity
# exceeds 24 mm h -1 (Wischmeier and Smith, 1978)
	for(K=0;K<=72;K++)
		{
		sprec= sprec + rain[I+K]
		}

	if (sprec <= 1.3) # Wischmeier and Smith threshold, 1978
		{	
		episode[I]= 0.0;
		}
		else
		{
		#if episode detecthed then:
		episode[I]= 1;
                     #Calculate I30
		     for(K=0;K<=5;K++)
			{
			I30[I]= (I30[I] + rain[I+K]);
			}
                     #I15
		     for(K=0;K<=3;K++)
			{
			 I15[I]= (I15[I]+rain[I+K]);
			}
                     #I10
		     for(K=0;K<=1;K++)
			{
			 I10[I]= (I10[I]+rain[I+K]);
			}
                     #I5
                        I5[I]=rain[I]; 
# Uncomment the line below for testing:
# print I,I5[I]*12,I10[I]*6,I15[I]*4,I30[I]*2
		if(episode[I] > episode[I-1] && episode[I] > 0)
			{
			nepisode= nepisode + 1;
			}
         snepisode[I]=nepisode;
		}



if(episode[I] > 0)

{
# Uncomment the line below for testing:
# print I,prec[I],episode[I],snepisode[I],I5[I]*12,I10[I]*6,I15[I]*3,I30[I]*2,MaxI30*2


if(rain[I] > 0)
{

Pepisode[snepisode[I]] = Pepisode[snepisode[I]] + rain[I];
time[snepisode[I]]++;
}

	tmp5 =   I5[I-1];
	tmp10 = I10[I-1];
	tmp15 = I15[I-1];
	tmp30 = I30[I-1];


	if(tmp5 < I5[I]) { tmp5 =I5[I]; }
	if(tmp10 < I10[I]) { tmp10 =I10[I]; }
	if(tmp15 < I15[I]) { tmp15 =I15[I]; }
	if(tmp30 < I30[I]) { tmp30 =I30[I]; }
 

#	vI5[snepisode[I]]=tmp5*12
#	vI10[snepisode[I]]=tmp10*6
#	vI15[snepisode[I]]=tmp15*3
#       vI30[snepisode[I]]=tmp30*2


# Calculates the maximum rainfall intensity for different periods
# and expresses in (mm/h) in the episode.
#e.g., for  (maxI30) in 30 min
	if(maxI30 < tmp30) { maxI30=tmp30; }
	if(maxI15 < tmp15) { maxI15=tmp15; }
	if(maxI10 < tmp10) { maxI10=tmp10; }
	if(maxI5 < tmp5)   { maxI5=  tmp5; }

	#Store the maximum intensiities in variables indexed by episodes
	vI30[snepisode[I]]=maxI30*2;
	vI15[snepisode[I]]=maxI15*3;
	vI10[snepisode[I]]=maxI10*6;
	vI5[snepisode[I]]=maxI5*12;

#Calculates the rainfall energy in the episode (RE) by using the Brown and Foster equation (1987).

	RE[snepisode[I]]=energy(Pepisode[snepisode[I]]/time[snepisode[I]]*12.0)* Pepisode[snepisode[I]];

	EI30[snepisode[I]]=RE[snepisode[I]]*vI30[snepisode[I]];
	EI15[snepisode[I]]=RE[snepisode[I]]*vI15[snepisode[I]];
	EI10[snepisode[I]]=RE[snepisode[I]]*vI10[snepisode[I]];
	 EI5[snepisode[I]]=RE[snepisode[I]]* vI5[snepisode[I]];

# Uncomment the line below for testing:
#print rain[I],snepisode[I],vI5[snepisode[I]], vI10[snepisode[I]], vI15[snepisode[I]], vI30[snepisode[I]],RE[snepisode[I]],EI30[snvent[I]] 


#Stores the date and time in an array indexed by episodes
	datepisode[snepisode[I]] = date[I];
	timepisode[snepisode[I]] = time[I];

# Uncomment the line below for testing:
#print date[I],time[I],rain[I],snepisode[I],Pepisode[snepisode[I]],vI30[snepisode[I]],RE[snepisode[I]],EI30[snepisode[I]]; 


# Save the maximum number of episodes
	maxepisode=snepisode[I];
	}

# Uncomment the line below for testing:
#	print I5[I]*12,I10[I]*6,I15[I]*4,I30[I]*2
}

#=================================================================
# Write output:
# date, time, episode no., EI30 (MJ/ha mm/h)
#=================================================================

for(Istorm=1;Istorm<=maxepisode;Istorm++)
{
# Uncomment the line below for testing:
# print Istorm,datepisode[Istorm],timepisode[Istorm],EI30[Istorm]
printf "%s\t%s\t%3d\t%4.1f\t%4.1f\t%4.1f\t%4.1f\n",datepisode[Istorm],timepisode[Istorm],Istorm,EI5[Istorm],EI10[Istorm],EI15[Istorm],EI30[Istorm]

}


}



#=================================================================
#The rainfall energy  is calculated for each time interval as:
#where rain_intensity is the rainfall intensity during 
# the time interval (mm hr -1).
# Formula de Brown y Foster 1987
# returns the energy  in  E(MJ/ha)
function energy(rain_intensity)
	{
	res = 0.29 * (1 - 0.72 * exp(-0.05 * rain_intensity))
	return(res)
	}
#-----------------------------------------------------------------

# References:
#
#
# Brown, L.C. and Foster, G.R. 1987. Storm erosivity using idealized
# intensity distributions. Transaction of the ASAE 30:379-386.
#
# Wischmeier, W.H. and D.D. Smith. 1978. Predicting rainfall-
# erosion losses - A guide to conservation farming. U.S. Dept.
# of Agric., Agr. Handbook No. 537.
#-----------------------------------------------------------------
