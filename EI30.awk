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


# Command line assignation of time interval  (in minutes)
# interval = ARGV[1];
interval = 5;

 t5 = 60/interval;
t10 = 30/interval;
t15 = 15/interval;
t30 = 10/interval;

tdry = int(60/interval*6);

printf "#==========================================================================\n"
printf "# Calculation of EI erosivity indexes from tipping buckett rainfall records\n"
printf "# Using a time lag of %d min\n",interval
printf "===========================================================================\n"
printf "Date\tTime\t\tEvt_no.\tP(mm)\tTime(h)\tAvg_I(mm/h)\tI5\tI10\tI15\tI30\tEnergy\tEI5\tEI10\tEI15\tEI30\n"

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
	for(K=0;K<=tdry;K++)
		{
		sprec= sprec + rain[I+K]
		}

	if (sprec <= 1.3) # Threshold for erosive rain > 1.3 mm (Wischmeier and Smith, 1978)
		{	
		episode[I]= 0;
		}
		else
		{
		#if episode detected then:
		episode[I]= 1;
                     #Calculate I30
		     for(K=0;K<=int(30/interval-1);K++)
			{
			I30[I]= (I30[I] + rain[I+K]);
			}
                     #I15
		     for(K=0;K<=int(15/interval-1);K++)
			{
			 I15[I]= (I15[I]+rain[I+K]);
			}
                     #I10
		     for(K=0;K<=int(10/interval-1);K++)
			{
			 I10[I]= (I10[I]+rain[I+K]);
			}
                     #I5
                        I5[I]=rain[I]; 
# Uncomment the line below for testing:
# print date[I],time[I],I,nepisode,I30[I]

# Set the array index in the previuos record
M =  I-1;
		if(episode[I] > episode[M] && episode[M] < 1)
			{
			nepisode++;
			}


# Save the   number of the episode
         sumep[I]=nepisode;
# Save the  time indexes in the episodes
         timeindex[sumep[I]]=I;


#print sumep[I],timeindex[sumep[I]]



# Uncomment the line below for testing:
# print date[I],time[I],I,prec[I],episode[I],sumep[I],I30[I],Pepisode[sumep[I]]

	tmp5 =   I5[M];
	tmp10 = I10[M];
	tmp15 = I15[M];
	tmp30 = I30[M];


	if(tmp5 < I5[I]) { tmp5 =I5[I]; }
	if(tmp10 < I10[I]) { tmp10 =I10[I]; }
	if(tmp15 < I15[I]) { tmp15 =I15[I]; }
	if(tmp30 < I30[I]) { tmp30 =I30[I]; }
 

# Compute the maximum rainfall intensity for different periods
# and expresses in (mm/h) in the episode.
#e.g., for  (maxI30) in 30 min
	if(maxI30 < tmp30) { maxI30=tmp30; }
	if(maxI15 < tmp15) { maxI15=tmp15; }
	if(maxI10 < tmp10) { maxI10=tmp10; }
	if(maxI5 < tmp5)   { maxI5=  tmp5; }

	#Store the maximum intensities in variables indexed by episodes
	vI30[sumep[I]]=maxI30*t30;
	vI15[sumep[I]]=maxI15*t15;
	vI10[sumep[I]]=maxI10*t10;
	vI5[sumep[I]]=maxI5*t5;

#Calculates the rainfall energy in the episode (RE) by using the Brown and Foster equation (1987).

#	RE[sumep[I]]=energy(Pepisode[sumep[I]]/time[sumep[I]]*(60.0/interval))* Pepisode[sumep[I]];
#	RE[sumep[I]]=energy(Pepisode[sumep[I]]/timep[sumep[I]]*(60.0/interval));


# Uncomment the line below for testing:
#printf"%d\t%d\t%2.1f\t%2d\t%3.1f\t%3.1f\t%3.1f\t%3.1f\t%3.1f\t%3.1f\n",time[I],date[I],rain[I],sumep[I],vI5[sumep[I]],vI10[sumep[I]],vI15[sumep[I]],vI30[sumep[I]],RE[sumep[I]],EI30[snvent[I]]


N = I + int(30/interval);

#Stores the date and time in an array indexed by episodes
	datepisode[sumep[I]] = date[N];
	timepisode[sumep[I]] = time[N];

# Uncomment the line below for testing:
#print date[I],time[I],rain[I],sumep[I],Pepisode[sumep[I]],vI30[sumep[I]],RE[sumep[I]],EI30[sumep[I]]; 


# Save the maximum number of episodes
	maxepisode=sumep[I];
	}
# End of the conditional loop  for the episode

# Uncomment the line below for testing:
#	print I5[I]*12,I10[I]*6,I15[I]*4,I30[I]*2
}


for(Istorm=1;Istorm < maxepisode; Istorm++)
{
	for(K=timeindex[Istorm];K <= timeindex[M];K++)
	{
         
	}

}


for(Istorm=1;Istorm < maxepisode; Istorm++)
{
#print maxepisode

M = Istorm + 1;

	for(K=timeindex[Istorm];K <= timeindex[M];K++)
	{
	Pepisode[Istorm] = Pepisode[Istorm] + rain[K];
         
        timet[Istorm]++;
	if( rain[K] > 0) {timep[Istorm]++;}
	}	
	RE[Istorm]=energy(Pepisode[Istorm]/timep[Istorm]*(60.0/interval));

# Uncomment the line below for testing:
#	print timep[Istorm],Pepisode[Istorm],RE[Istorm]

}
#=================================================================
# Write output:
# date, time, episode no., EI30 (MJ/ha mm/h)
#=================================================================

for(Istorm=1;Istorm <= maxepisode-1;Istorm++)
{
 
raintime=timep[Istorm]*interval/60.0;

#Compute the average rainfall intensity in the interval
Avg_I= Pepisode[Istorm]/raintime;

	RE[Istorm]=energy(Avg_I);

	EI30[Istorm]=RE[Istorm]*vI30[Istorm];
	EI15[Istorm]=RE[Istorm]*vI15[Istorm];
	EI10[Istorm]=RE[Istorm]*vI10[Istorm];
	 EI5[Istorm]=RE[Istorm]* vI5[Istorm];

# Uncomment the line below for testing:
# print Istorm,datepisode[Istorm],timepisode[Istorm],EI30[Istorm]
printf "%s\t%s\t%3d\t%3.1f\t%4.1f\t%4.1f\t%3.1f\t%4.1f\t%4.1f\t%4.1f\t%4.3f\t%4.1f\t%4.1f\t%4.1f\t%4.1f\n",datepisode[Istorm],timepisode[Istorm],Istorm,Pepisode[Istorm],raintime,Avg_I,vI5[Istorm],vI10[Istorm],vI15[Istorm],vI30[Istorm],RE[Istorm],EI5[Istorm],EI10[Istorm],EI15[Istorm],EI30[Istorm]

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
