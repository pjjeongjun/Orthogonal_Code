<!DOCTYPE html>
<html>
    
<head>
    <h1>Data description</h1>
</head>

<body> 
<b>1. 'firingRates_directions_n_normalized'</b>
<p>Z-scored firing rates for each PFC memory cell in the look/no-look tasks.<br>
n: 1 of 60 distinct sets of the 6 target direction bins, with each subsequent set shifted by 1 degree (see preprint for details).
</p>
</body>   

<head>
    <h1>Code description</h1>
</head>  

<body> 
<b>1. 'run_dPCA.m'</b>
<p>Define dPCs for spatial memory using the early delay period activity (0-500 ms from target offset).</p>
</body>    

<body> 
<b>2. 'decode_direction.m'</b>
<p>Decode target direction using the early delay period activity projected in the memory subspace </p>
</body>    

<body> 
<b>3. 'plot_accuracy.m'</b>
<p>Plot decoding performance of the task-specific and shared of memory subspace</p>
</body>    

</html>
