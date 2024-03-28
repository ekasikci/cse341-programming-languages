% place(ID)
place('Admin Office').
place('Engineering Bld.').
place('Library').
place('Lecture Hall A').
place('Cafeteria').
place('Social Sciences Bld.').
place('Institute X').
place('Institute Y').

% route(Place1, Place2, Distance)
route('Admin Office', 'Engineering Bld.', 3).
route('Library', 'Engineering Bld.', 5).
route('Lecture Hall A', 'Engineering Bld.', 2).
route('Admin Office', 'Library', 1).
route('Cafeteria', 'Admin Office', 4).
route('Cafeteria', 'Library', 5).
route('Cafeteria', 'Social Sciences Bld.', 2).
route('Library', 'Social Sciences Bld.', 2).
route('Social Sciences Bld.', 'Institute X', 8).
route('Library', 'Institute Y', 3).
route('Lecture Hall A', 'Institute Y', 3).

% delivery_person(ID, Capacity, WorkHours, CurrentJob, CurrentLocation)
delivery_person(p1, 10, 16, none, 'Admin Office').
delivery_person(p2, 5, 24, none, 'Library').
delivery_person(p3, 20, 8, o3, 'Engineering Bld.').

% object(ID, Weight, PickUpPlace, DropOffPlace, Urgency, DeliveryPersonID)
object(o1, 10, 'Admin Office', 'Engineering Bld.', medium, none).
object(o2, 3, 'Library', 'Lecture Hall A', low, none).
object(o3, 1, 'Cafeteria', 'Social Sciences Bld.', high, p3).
object(o4, 5, 'Institute X', 'Institute Y', low, none).
object(o5, 4, 'Engineering Bld.', 'Admin Office', high, none).

% Check if the object is already in delivery
delivery_status(ObjectID, PersonID, 'Already in delivery') :-
    object(ObjectID, _, _, _, _, PersonID),
    PersonID \= none.

% Find available delivery persons and calculate total delivery time for the shortest route
delivery_status(ObjectID, PersonID, TotalTime) :-
    object(ObjectID, Weight, PickUpPlace, DropOffPlace, _, none),
    delivery_person(PersonID, Capacity, WorkHours, none, CurrentLocation),
    Weight =< Capacity,
    (   CurrentLocation = PickUpPlace
    ->  PickUpTime = 0
    ;   find_shortest_route(CurrentLocation, PickUpPlace, _, PickUpTime)
    ),
    find_shortest_route(PickUpPlace, DropOffPlace, _, DeliveryTime),
    TotalTime is PickUpTime + DeliveryTime,
    TotalTime =< WorkHours.


% Calculate total delivery time
total_delivery_time(CurrentLocation, PickUpPlace, DropOffPlace, TotalTime) :-
    route_distance(CurrentLocation, PickUpPlace, Time1),
    route_distance(PickUpPlace, DropOffPlace, Time2),
    TotalTime is Time1 + Time2.

% Bidirectional routes
route_distance(Place1, Place2, Distance) :-
    (route(Place1, Place2, Distance) ; route(Place2, Place1, Distance)).

% Find the shortest path and its distance between two places
find_route(Start, End, Path, TotalDistance) :-
    travel(Start, End, [Start], 0, RevPath, TotalDistance),
    reverse(RevPath, Path).

% Recursive travel predicate
travel(Start, End, Visited, DistAcc, [End|Visited], TotalDistance) :-
    route_distance(Start, End, Dist),
    TotalDistance is DistAcc + Dist.

travel(Start, End, Visited, DistAcc, Path, TotalDistance) :-
    route_distance(Start, Next, Dist),
    Next \= End,
    \+ member(Next, Visited), % prevent loops
    NewDistAcc is DistAcc + Dist,
    travel(Next, End, [Next|Visited], NewDistAcc, Path, TotalDistance).


% Find the shortest path and its distance between two places
find_shortest_route(Start, End, ShortestPath, ShortestDistance) :-
    findall([RevPath, TotalDistance], travel(Start, End, [Start], 0, RevPath, TotalDistance), Paths),
    select_shortest_path(Paths, ShortestPath, ShortestDistance).

% Select the shortest path from a list of paths
select_shortest_path(Paths, ShortestPath, ShortestDistance) :-
    sort(2, @=<, Paths, SortedPaths),
    SortedPaths = [[ShortestRevPath, ShortestDistance]|_],
    reverse(ShortestRevPath, ShortestPath).



