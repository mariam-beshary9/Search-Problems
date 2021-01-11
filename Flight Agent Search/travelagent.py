"""TravelAgent.ipynb
Automatically generated by Colaboratory.
Original file is located at
    https://colab.research.google.com/drive/1fMsbmmywQmjpEX3m08LQ8Kmo07M8RjwO
"""

from pandas import read_excel

# read the data NOTE: I had to modify the excel sheet manually because city 'Lyon' sometimes is written 'Lyon ' and sometimes 'Lyon' so the additional space caused some errors
cities = read_excel('Travel Agent KB (2 sheets).xlsx', sheet_name = 'Cities')
flights= read_excel('Travel Agent KB (2 sheets).xlsx', sheet_name = 'Flights')


# preprocessing of data 
from datetime import time
duration = []
flightDays = []
days = []

for index, row in flights.iterrows():
  # modify the data type of days to be lists instead of string
  df = row['List of Days'][1:len(row['List of Days'])-1].split(', ')
  days.append(df)

  # getting the duration of flights in hours and minutes
  durationHours = row['Arrival Time'].hour - row['Departure Time'].hour
  durationMinutes= row['Arrival Time'].minute - row['Departure Time'].minute
  if (durationHours<0):
   durationHours+=24
   # to know if the flight ended in a different day from the day it began with
   flightDays.append(2)
  else: 
    flightDays.append(1)
  if(durationMinutes<0):
    durationMinutes+=60
    
  d = time(hour=durationHours, minute=durationMinutes, tzinfo=None)
  duration.append(d)

# adding generated data to the dataframe
flights['Duration time'] = duration
flights['Duration Days'] = flightDays
flights['List of Days'] = days

from sklearn.metrics.pairwise import haversine_distances
from math import radians  

# a funtion that calculates the time between two cities based on their longitude and latitude values (get the distance and multiply it by the inverse of light speed)
def getHeuristic(sourc,destinat):
  sourceRecord =  cities.loc[cities['City'] == sourc]
  destinationRecord=cities.loc[cities['City'] == destinat]
 
  s = [sourceRecord['Longitude'],sourceRecord['Latitude'] ]
  d = [destinationRecord['Longitude'],destinationRecord['Latitude'] ]
  s_in_radians = [radians(_) for _ in s]
  d_in_radians = [radians(_) for _ in d]
  
  result = haversine_distances([s_in_radians, d_in_radians])
  result * 6371000/1000  
  # time(sec) = distance (km)*(1/lightSpeed(km/sec))
  return result[0][0]*(1/299792.458)

# a function that return the index of path that has the least cost in the openList
def getIndexofMinPath(open_List,destin):
  minIndex = 0
  minValue = open_List[0][1] + getHeuristic(open_List[0][0][len(open_List[0][0])-1],destin)
  
  for i in range (1,len(open_List)):
    if(open_List[i][1]+getHeuristic(openList[i][0][len(open_List[i][0])-1],destin)<minValue):
      minValue = open_List[i][1] +getHeuristic(open_List[i][0][len(open_List[i][0])-1],destin)
      minIndex = i
  return minIndex

#a function that gets the index of a specific city in the open list, it returns -1 if it does not exist
def indexInOpenList(open__list,city):
  for i in range (0,len(open__list)):
    if (open__list[i][0][len(open__list[i][0])-1]==city):
       return i
  return -1


weekDays = ['sat','sun','mon','tue','wed','thu','fri','sat','sun','mon','tue','wed','thu','fri']
while(True):

  print()
  print("Your query should be in the format'Print_solution(travel(source,destination,[tue,wed]))' be aware of capital letters")
  query  = input('Enter your Query: ')
  
  #split the query by "(" and check if words are written right , then extract cities and days
  queryParts = query.split('(')
  if((queryParts[0]!='Print_solution')or(queryParts[1]!='travel')):
    print ("Invalid query")
    continue
  source = queryParts[2].split(',')[0]
  destination = queryParts[2].split(',')[1]

  # validate source and destination and day
  if(cities['City'].to_list().count(source)==0):
    print("The source does not exist")
    continue

  if(cities['City'].to_list().count(destination)==0):
    print("The destination does not exist")
    continue

  startDay = queryParts[2].split(',')[2][1:]
  
  endDay =queryParts[2].split(',')[3][:len(queryParts[2].split(',')[3])-3]

  startIndex = weekDays.index(startDay)
  if (startIndex==0):
    startIndex +=7

  # getting two arrays one contains only query days and the other contains both query days and additional two days (we use it if the solution of query days is empty)
  queryDays = weekDays[startIndex:(weekDays[startIndex:].index(endDay)+startIndex)]
  extraQueryDays =weekDays[startIndex-1:(weekDays[startIndex:].index(endDay)+startIndex+1)]

  #for query days
  solutions = []
  #for query days and the extra two days (after and before)
  additionalSolutions=[]

  # loop over all days
  for oneQueryDay in extraQueryDays:

    openList = []
    closedList = []
    openList.append([[source],0,[]])
    tempDay = oneQueryDay

    while (len(openList)>0):
      #get the index of the least (total path cost + heuristic cost) from the open list
      minIndex =getIndexofMinPath(openList,destination)
      decisionCity=openList[minIndex].copy()
      #remove the selected path
      openList.remove(decisionCity)
      closedList.append(decisionCity[0][len(decisionCity[0])-1])

      #if the goal is reached
      if(decisionCity[0][len(decisionCity[0])-1]==destination):
        #if the day belongs to query days 
        if(queryDays.count(oneQueryDay)>0):
          solutions.append([decisionCity[2][0],decisionCity[1]])
          break
        else: 
          additionalSolutions.append([decisionCity[2][0],decisionCity[1]])
          break
      
      else: 
        #filter all flights to get new available flights for the city 
        flightTableofCity = flights[flights.Source == decisionCity[0][len(decisionCity[0])-1]]

        # getting the previous path data (flights numbers of the path and the arrival time of the last flight) to measure waiting time
        if(len(decisionCity[2])>0):
          flightNumber=decisionCity[2][0]
          travelLastTime=decisionCity[2][1]
        
    # looping over each successor
        for index, row in flightTableofCity.iterrows():
          # if this flight is not in the current day
          if(row['List of Days'].count(tempDay)==0):
            continue

          waitingTime=0
          if(len(decisionCity[2])>0):
            waitingTime = ((row['Departure Time'].hour*60*60)+(row['Departure Time'].minute*60))-(travelLastTime.hour*60*60)+(travelLastTime.minute*60)

          # means that the next flight is before the previous one
          if (waitingTime<0):
            continue

          #cost = waiting time + the duration of the flight + the duration of the previous path
          cost = waitingTime+(row['Duration time'].hour*60*60)+(row['Duration time'].minute*60)+decisionCity[1]
         
         # update the curent day if the flight exceeds the day 
          if(row['Duration Days']==2):
            ind = weekDays.index(tempDay)
            tempDay=weekDays[ind+1]

         # if the adjacent node (the successor) is not in the closed list
          if(closedList.count(row['Destination'])==0):
            # we get its index in pen list
            indexOpenList = indexInOpenList(openList,row['Destination'])
            # if it is not found we append it to open list
            if(indexOpenList==-1):
              path =decisionCity[0].copy()
              path.append(row['Destination'])
              if(len(decisionCity[2])==0):
                flightNumber =[]
              flightNumber1 = flightNumber.copy() # array represents all flight numbers of the path untin the successor
              flightNumber1.append(row['Flight Number'])
              openList.append([path,cost,[flightNumber1,row['Arrival Time']]])
              
            # if it is found, we compare the new cost of it with the previous cost and update it with the minimum
            else:    
              if (cost < openList[indexOpenList][1]):
                openList[indexInOpenList(openList,row['Destination'])][1] = cost
    
  finalSolution = []   
  # if the size of the solutions within only query days >0 -> we find the path with minimum cost and assign it to finalSolution 
  if(len(solutions)>0):
    minSolution = solutions[0]
    for i in range(1,len(solutions)):
      if(solutions[i][1]<minSolution[1]):
        minSolution = solutions[i]
    finalSolution.append(minSolution)

  # else we see additionalSolutions
  else:
    if(len(additionalSolutions)>0):
      minSolution = additionalSolutions[0]
      for i in range(1,len(additionalSolutions)):
        if(additionalSolutions[i][1]<minSolution[1]):
          minSolution = additionalSolutions[i]
      finalSolution.append(minSolution)
  if (len(finalSolution)>0):
    counter =1
    # printing the solution 
    for i in finalSolution[0][0]:
      record = flights[flights['Flight Number'] == i]
      print("Step ",counter," : use flight ",i," from ",record['Source'].values[0]," to ",record['Destination'].values[0],", Departure time ",record['Departure Time'].values[0]," and arrival time ",record['Arrival Time'].values[0],".")
      counter+=1
  else: 
    #print (openList)
    #print(solutions)
    #print (additionalSolutions)
    print("There is no path")