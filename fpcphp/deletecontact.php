<?php ini_set( "display_errors", 0); 

require_once("dbcon.php");

$method = $_SERVER['REQUEST_METHOD'];
$input  = json_decode(file_get_contents('php://input'),true);

if (($method=='POST') && !empty($input['id'])){
	
	$id = mysqli_escape_string($con,$input['id']);
	
	$sql = "DELETE FROM contact where id='".$id."'";
										
	if (!mysqli_query($con,$sql)) { 			
		
		$out_fail 	= json_encode(array("Status"=>"FAIL", "Respon"=>"Delete Contact Gagal!"));		
		echo $out_fail;
	
	} else {
		
		$out_sukses = json_encode(array("Status"=>"DONE", "Respon"=>"Delete Contact Sukses!"));
		echo $out_sukses;
		
	}
				
} else {
	
	$out_fail 	= json_encode(array("Status"=>"FAIL", "Respon"=>"Empty Parameter!"));		
	echo $out_fail;
	
}

?>