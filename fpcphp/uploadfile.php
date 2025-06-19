<?php ini_set( "display_errors", 0); 
	
$target_path = "upload/"; 
$target_path = $target_path . basename( $_FILES['fileupload']['name']); 

if(move_uploaded_file($_FILES['fileupload']['tmp_name'], $target_path)){
	
	$out_sukses = json_encode(array("Status"=>"DONE", "Respon"=>"Berhasil Upload File"));
	echo $out_sukses;
		
} else { 
    
	$out_fail 	= json_encode(array("Status"=>"FAIL", "Respon"=>"Gagal Upload File"));		
	echo $out_fail;

}

?> 