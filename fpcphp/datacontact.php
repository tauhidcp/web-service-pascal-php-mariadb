<?php ini_set( "display_errors", 0); 

require_once("dbcon.php");

$sql 	= "SELECT * FROM contact";
$result = mysqli_query($con,$sql);

echo '[';
for ($i=0; $i<mysqli_num_rows($result); $i++){
	
    echo ($i>0?',':'').json_encode(mysqli_fetch_object($result));
  
  }
echo ']';

?>