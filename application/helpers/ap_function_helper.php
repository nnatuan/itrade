<?php if (!defined('BASEPATH')) exit('No direct script access allowed');


function Fset_userdata($str_session_name, $obj_session_value)
	{								
		$_SESSION[$str_session_name] = $obj_session_value;   
	}		  


function Funset_userdata($str_session_name)
	{	
		if (isset($_SESSION[$str_session_name])) 
			unset ($_SESSION[$str_session_name]); 
	}		 


function Fget_userdata($str_session_name) 
	{
		if (isset($_SESSION[$str_session_name]))
			return $_SESSION[$str_session_name]; 
		else
		{
			$_SESSION[$str_session_name]=''; 
			return $_SESSION[$str_session_name]; 
		}
	}


function Fget_encode($str_data = '')
	{
		if(empty($str_data))
			return $str_data;
			
		if(trim($str_data)=='')
			return $str_data;	
		else
			return md5($str_data);	
	}

	
function Fget_tkbencode($str_data = '')
	{		
		return $str_data;	
	}
//
//
//
function Fget_tkbdecode($str_data = '')
	{
		return $str_data;	
	}


function Fview_text($str_value)
	{
		if( empty($str_value ) OR trim($str_value)=="")
			return "&nbsp;";
		else
			return $str_value;
	}	

function Fview_textarea($str_value)
	{
		if( empty($str_value ) OR trim($str_value)=="")
			return "&nbsp;";
		else
			return $str_value;
	}	
 

function Fview_number($num_number)
	{
		if( empty($num_number ) OR trim($num_number)=='')
			return '&nbsp;';
		else
			return round($num_number,2);
	}
	

function Fview_date($dat_date)
	{
		if( empty($dat_date) OR trim($dat_date)=='' OR trim($dat_date)=='--')
			return '&nbsp;';
		else 
			return date('d/m/Y',strtotime($dat_date));
	}	
	

function Fget_ap_table($tablename='')
  	{
    	//return trim(Fget_userdata('session_ap_prefix')).'_'. $tablename;
			$CI =& get_instance();
		return $CI->config->item('system_ap_prefix').'_'. $tablename;
  	}
//
// Ham tra ve nguyen tac hien thi thong tin phan nhanh
//
function Fget_ap_table2($tablename='')
  	{
		$CI =& get_instance();
		return $CI->config->item('system_ap_prefix').'_'. $tablename;
  	}
	
	
function Fview_textindex($index)
   {
	   $m = '';
       if(strlen($index) == 5 || strlen($index) == 10)
		  return $m;
	   else 
	   {
		 $index = (strlen($index)-5)/5 - 1; 
		 for($n=1;$n<=$index;$n++)
			$m = '|_ _ ' . $m;
		  return $m;										 
	   }
	}


function Fget_total_page($num_row_per_page, $num_total_row)
	{
		if($num_row_per_page == 0)
			$num_row_per_page = 1;
		
		if($num_total_row % $num_row_per_page == 0)
			return $num_total_row / $num_row_per_page;
		else
			return ($num_total_row - ($num_total_row % $num_row_per_page)) / $num_row_per_page + 1;
	}		


 function Fget_icon_notnull()
 	{
		$icon_notnull = ' <span style="color:red; font-size:16px"> * </span> ';
		return $icon_notnull;
	} 

function Fget_image_sort($str_sort='acs')
	{ 
		if($str_sort == 'asc')
			return '<img src="' . base_url() . 'images/icons/asc.png" alt="sort"/>';
		else
			return '<img src="' . base_url() . 'images/icons/desc.png" alt="sort"/>';
	}
//
//
//
function Farray_insert(&$array,$pos,$val)
	{
		$array2 = array_splice($array,$pos);
		$array[] = $val;
		$array = array_merge($array,$array2);
	}		
//
//

function Fconvert_to_int($value='')
  	{
    	return intval($value);
  	}
//
//
//	
function Fis_char_number($value)
  	{
    return (preg_match ("/^(-){0,1}([0-9]+)(,[0-9][0-9][0-9])*([.,][0-9]){0,1}([0-9]*)$/", trim($value)) == 1);
  	}

function Fis_date_null($value)
  	{
    	if(trim($value)=='' OR trim($value)=='01/01/1970')
			return TRUE;
		else
			return FALSE;	
  	}
function Fis_email($value)
  	{
    	if(trim($value)<>'')
			return TRUE;
		else
			return FALSE;
  	}
	
function Fis_date($value)
  	{
		$blnValid = TRUE;
   		// check the format first (may not be necessary as we use checkdate() below)
   		if(!ereg ("^[0-9]{2}/[0-9]{2}/[0-9]{4}$", $value))
   		{
    		$blnValid = FALSE;
   		}
   		else //format is okay, check that days, months, years are okay
   		{
      		$arrDate = explode("/", $value); // break up date by slash
      		$intDay = $arrDate[0];
      		$intMonth = $arrDate[1];
      		$intYear = $arrDate[2];
				
			if ($intYear%4!=0 AND $intMonth==2 AND $intDay==29)
				$blnValid = FALSE;
			else
				{	      		
				$intIsDate = checkdate( $intMonth, $intDay,$intYear);
     			if(!$intIsDate)
        			$blnValid = FALSE;
				}	
   		}//end else
   		return ($blnValid);
  	}
	
//
// Phai dam bao co day du 10 ky tu so
//	
function Fget_strdate($value)
  	{
    	$str_day=''; 
		$str_month='';
		$str_year='';
		$str_day 	= substr($value, 0, 2);
		$str_month	= substr($value, 3, 2); 
		$str_year	= substr($value, 6, 4); 
		if (trim($value)=='')
			return '';
		else			
			return $str_year . '-'. $str_month . '-' . $str_day;
  	}

//
// Ham chuyen mot so sang chuoi index theo dung nguyen tac 5 ky tu.
// Phai bao dam la kieu so.
// Chi su dung 5 ky tu de thuc hien.
//
function Fget_convert_index($value)
  	{
		$str='0000.';
		$value=trim($value);
		
		if ($value=='')
			$value = $str;
		else if (strlen($value)>4)
			$str = substr($value, 0, 4).'.';	
		else
			$str = substr($str, 0, 4-strlen($value)) . $value . '.';
		 	
		return $str;
  	}
//
// Xac dinh lai thong tin key index
// Phai dam bao da kiem tra day du 5 ky tu
// Chi su dung 5 ky tu de thuc hien.
// $index la gia tri key index da duoc chuyen doi.
// $current_index la gia tri cac index con can chuyen doi phu hop voi he thong.
function Fget_parent_index($value)
  	{
		$str = '';
		$value=trim($value);
				
		if (strlen($value)<=5)
			$value = $str;
		else
			$value = substr($value, 0, strlen($value)-5);			
		return $value;
  	}
//
// Xac dinh lai thong tin key index
// Phai dam bao da kiem tra day du 5 ky tu
// Chi su dung 5 ky tu de thuc hien.
// $index la gia tri key index da duoc chuyen doi.
// $current_index la gia tri cac index con can chuyen doi phu hop voi he thong.
function Fget_change_key_index($old_parent_index,$new_parent_index, $current_index)
  	{		
		$new_parent_index 	= trim($new_parent_index);
		$old_parent_index 	= trim($old_parent_index);
		$current_index 		= trim($current_index);
				
		return $new_parent_index .  substr($current_index, strlen($old_parent_index), 
							strlen($current_index) - strlen($old_parent_index)) ;				
  	}
			
			

//function del file 
//param:file name
//
function delfile($str_name)
{
        if(is_file($str_name)){
            return @unlink($str_name);
		}
}

//function replace str
//param:str_search,str_replace,str
//
function Fstr_replace($str_search,$str_replace,$str)
{
        if(strlen($str) > 0){
            return str_replace($str_search,$str_replace,$str);
		}else
		return '';
}
//Upload không resize image
function Fupload_img_non_resize($file,$path,$modwidth,$modheight)
{
	$file_name='';
	if ((($file["type"] == "image/gif") || ($file["type"] == "image/jpeg")|| ($file["type"] == "image/png")|| ($file["type"] == "image/webp")|| ($file["type"] == "image/pjpeg"))&& ($file["size"] < 2000000))
		{
		if ($file["error"] > 0)
			{
				$msg= "Co loi khi upload anh: " . $_FILES["image2"]["error"] . "<br />";
				
 	 		}
			else
			{
			  	//list($name,$ext) = explode(".",$file["name"]);
			  	//Upload image vao thu muc nao
				//$duongdan = 'pc01/hvm_cms/upload/images/';
				$file_name = explode(".", $file["name"]);
			  	$file_name = $file_name[0].'_'.date('Ymdhis').'.'.$file_name[1];
			  	move_uploaded_file($file["tmp_name"],$path.$file_name);
			  }
		
		}	
	return 	$file_name;
}
//upload resize IMG
function Fupload_resize_img($file,$path,$modwidth,$modheight)
{
	$file_name='';
	if ((($file["type"] == "image/gif") || ($file["type"] == "image/jpeg")|| ($file["type"] == "image/png")|| ($file["type"] == "image/webp")|| ($file["type"] == "image/pjpeg"))&& ($file["size"] < 2000000))
		{
		if ($file["error"] > 0)
			{
				$msg= "Co loi khi upload anh: " . $_FILES["image2"]["error"] . "<br />";
				
 	 		}
			else
			{
			  	//list($name,$ext) = explode(".",$file["name"]);
			  	//Upload image vao thu muc nao
				//$duongdan = 'pc01/hvm_cms/upload/images/';
				$file_name = explode(".", $file["name"]);
			  	$file_name = $file_name[0].'_'.date('Ymdhis').'.'.$file_name[1];
			  	move_uploaded_file($file["tmp_name"],$path.$file_name);
			  	
				//resize image trong hinh
				$imagepath = $path.$file_name;
				
				$save 		= $imagepath; //This is the new file you saving
				$file_tmp   = $imagepath; //This is the original file
				list($width, $height) = getimagesize($file_tmp) ; 
				
//				$modwidth =150;
//				$modheight=150;
				if($width>$modwidth || $height>$modheight)
				{
					$diff = $width / $modwidth;
	 
					$modheight = $height / $diff; 
					$tn = imagecreatetruecolor($modwidth, $modheight) ; 
			
					if(	($file["type"] == "image/gif")  || ($file["type"] == "image/jpeg"))				
					{
						$image = imagecreatefromjpeg($file_tmp) ; 
					}
					elseif ($file["type"] == "image/png")
					{
						$image = imagecreatefrompng($file_tmp);
					}
				
					imagecopyresampled($tn, $image, 0, 0, 0, 0, $modwidth, $modheight, $width, $height) ; 
		 
					imagejpeg($tn, $save, 100) ; 
				}
				//het resize
			  }
			
		
		}	
	return 	$file_name;
}
function webpConvert2($file, $compression_quality = 80)
{
    // check if file exists
    if (!file_exists($file)) {
        return false;
    }
    $file_type = exif_imagetype($file);
    //https://www.php.net/manual/en/function.exif-imagetype.php
    //exif_imagetype($file);
    // 1    IMAGETYPE_GIF
    // 2    IMAGETYPE_JPEG
    // 3    IMAGETYPE_PNG
    // 6    IMAGETYPE_BMP
    // 15   IMAGETYPE_WBMP
    // 16   IMAGETYPE_XBM
	
	/*
	$jpg=imagecreatefromjpeg('filename.jpg');
	$w=imagesx($jpg);
	$h=imagesy($jpg);
	$webp=imagecreatetruecolor($w,$h);
	imagecopy($webp,$jpg,0,0,0,0,$w,$h);
	imagewebp($webp, 'filename.webp', 80);
	imagedestroy($jpg);
	imagedestroy($webp);
	*/
	
    $output_file =  $file . '.webp';
    if (file_exists($output_file)) {
        return $output_file;
    }
    if (function_exists('imagewebp')) {
        switch ($file_type) {
            case '1': //IMAGETYPE_GIF
                $image = imagecreatefromgif($file);
                break;
            case '2': //IMAGETYPE_JPEG
                $image = imagecreatefromjpeg($file);
                break;
            case '3': //IMAGETYPE_PNG
                    $image = imagecreatefrompng($file);
                    imagepalettetotruecolor($image);
                    imagealphablending($image, true);
                    imagesavealpha($image, true);
                    break;
            case '6': // IMAGETYPE_BMP
                $image = imagecreatefrombmp($file);
                break;
            case '15': //IMAGETYPE_Webp
               return false;
                break;
            case '16': //IMAGETYPE_XBM
                $image = imagecreatefromxbm($file);
                break;
            default:
                return false;
        }
        // Save the image
        $result = imagewebp($image, $output_file, $compression_quality);
        if (false === $result) {
            return false;
        }
        // Free up memory
        imagedestroy($image);
        return $output_file;
    } elseif (class_exists('Imagick')) {
        $image = new Imagick();
        $image->readImage($file);
        if ($file_type === "3") {
            $image->setImageFormat('webp');
            $image->setImageCompressionQuality($compression_quality);
            $image->setOption('webp:lossless', 'true');
        }
        $image->writeImage($output_file);
        return $output_file;
    }
    return false;
}
function resize_img($file,$file_name,$path1,$path,$modwidth,$modheight)
{	
	copy($path1,$path.'resize_'.$file_name);
	//resize image trong hinh
	$imagepath = $path.'resize_'.$file_name;
	
	$save 		= $imagepath; //This is the new file you saving
	$file_tmp   = $imagepath; //This is the original file
	list($width, $height) = getimagesize($file_tmp) ; 

	if($width>$modwidth || $height>$modheight)
	{
		$diff = $width / $modwidth;

		$modheight = $height / $diff; 
		$tn = imagecreatetruecolor($modwidth, $modheight) ; 
		$image = '';
		if( $file["type"] == "image/jpeg" || $file["type"] == "image/pjpeg")				
		{
			$image = imagecreatefromjpeg($file_tmp) ;
		}
		elseif ($file["type"] == "image/png")
		{
			$image = imagecreatefrompng($file_tmp);
		}
		elseif ($file["type"] == "image/gif")
		{
			$image = imagecreatefromgif($file_tmp);
		}

		imagecopyresampled($tn, $image, 0, 0, 0, 0, $modwidth, $modheight, $width, $height) ; 

		imagejpeg($tn, $save, 100) ; 
	}
	
	return 'resize_'.$file_name;
	//het resize
}

/**
 *-------------------------------------------------------------------
 * @creator 		: Hoang Minh An - tieulong4000@yahoo.com
 * @finished date	: 2009/10/23
 * @description		: Thu vien dung chung cho cac combobox co, khong

 * @return string	: Gia tri hop le khi view html	
 */
function Fget_combobox_yes_no($blank_line,$str_name, $str_value, $str_style, $yes, $no)
 {
 	$str_return = '<select class="form-control" name = '.$str_name.' style="'.$str_style.'" >';

	if(trim($blank_line) == '')
		$str_return 	= $str_return.'<option selected="selected" value = "" ></option>';
	if(trim($str_value) == 1)
	{
		$str_return 	= $str_return.'<option selected="selected" value = "1">'.$yes.'</option>';
		$str_return 	= $str_return.'<option  value = "0">'.$no.'</option>';
	}
	if(trim($str_value) == 0 && trim($str_value) !='')
	{
		$str_return 	= $str_return.'<option  value = "1">'.$yes.'</option>';	
		$str_return 	= $str_return.'<option selected="selected" value = "0">'.$no.'</option>';
	}
	if(trim($str_value) == '')
	{
		$str_return 	= $str_return.'<option  value = "1">'.$yes.'</option>';	
		$str_return 	= $str_return.'<option  value = "0">'.$no.'</option>';
	}
	
	$str_return = $str_return.'</select>';
	return $str_return;
 }
 
function show_img_pulish($value)
{
	$str_return = '';
	if($value == 1)
		$str_return = '<img src="'.base_url().'images/publish.png" alt= "yes" />';
	if($value == 0)
		$str_return = '<img src="'.base_url().'images/unpublish.png" alt= "no" />';
	if($value == '')
		$str_return = '&nbsp;';
	return $str_return;
}

function show_img_pulish_active($link,$value)
{
	$str_return = '';
	if($value == 1)
		$str_return = '<a href="'.$link.'"><img src="'.base_url().'images/publish.png" alt= "yes" /></a>';
	if($value == 0)
		$str_return = '<a href="'.$link.'"><img src="'.base_url().'images/unpublish.png" alt= "no" /></a>';
	if($value == '')
		$str_return = '&nbsp;';
	return $str_return;
}

function show_text_pulish($value, $yes, $no)
{
	$str_return = '';
	if($value == 1)
		$str_return = $yes;
	if($value == 0)
		$str_return = $no;
	if($value == '')
		$str_return = '&nbsp;';
	return $str_return;
}

function show_menu_active($value1 = '', $value2= '')
{
	$str = '';
	if($value1 == $value2)
		$str = 'class="current"';
	else
		$str = '';
	return $str;
}

function Fstr_limit($string, $length, $replacer = ' ...')
{	
    if(strlen($string) > $length)
  	{
		$string = substr($string, 0, $length);
		$n = strrpos($string," ");
		return substr($string, 0, $n).$replacer;
 	 }
  return $string;

}
	
function khongdau($str) {
$str = trim($str);
$str = preg_replace("/(à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ)/", 'a', $str);
$str = preg_replace("/(è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ)/", 'e', $str);
$str = preg_replace("/(ì|í|ị|ỉ|ĩ)/", 'i', $str);
$str = preg_replace("/(ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ)/", 'o', $str);
$str = preg_replace("/(ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ)/", 'u', $str);
$str = preg_replace("/(ỳ|ý|ỵ|ỷ|ỹ)/", 'y', $str);
$str = preg_replace("/(đ)/", 'd', $str);
$str = preg_replace("/(À|Á|Ạ|Ả|Ã|Â|Ầ|Ấ|Ậ|Ẩ|Ẫ|Ă|Ằ|Ắ|Ặ|Ẳ|Ẵ)/", 'A', $str);
$str = preg_replace("/(È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ)/", 'E', $str);
$str = preg_replace("/(Ì|Í|Ị|Ỉ|Ĩ)/", 'I', $str);
$str = preg_replace("/(Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ)/", 'O', $str);
$str = preg_replace("/(Ù|Ú|Ụ|Ủ|Ũ|Ư|Ừ|Ứ|Ự|Ử|Ữ)/", 'U', $str);
$str = preg_replace("/(Ỳ|Ý|Ỵ|Ỷ|Ỹ)/", 'Y', $str);
$str = preg_replace("/(Đ)/", 'D', $str);
$str = str_replace("-", " ",$str);
$str = str_replace("/", "-",$str);
$str = str_replace(" ", "-", str_replace("&*#39;","",$str));
$str = strtolower($str);
return $str;
}

//You do not need to alter these functions
function resizeThumbnailImage($thumb_image_name, $image, $width, $height, $start_width, $start_height, $scale){
	list($imagewidth, $imageheight, $imageType) = getimagesize($image);
	$imageType = image_type_to_mime_type($imageType);
	
	$newImageWidth = ceil($width * $scale);
	$newImageHeight = ceil($height * $scale);
	$newImage = imagecreatetruecolor($newImageWidth,$newImageHeight);
	switch($imageType) {
		case "image/gif":
			$source=imagecreatefromgif($image); 
			break;
	    case "image/pjpeg":
		case "image/jpeg":
		case "image/jpg":
			$source=imagecreatefromjpeg($image); 
			break;
	    case "image/png":
		case "image/x-png":
			$source=imagecreatefrompng($image); 
			break;
  	}
	imagecopyresampled($newImage,$source,0,0,$start_width,$start_height,$newImageWidth,$newImageHeight,$width,$height);
	switch($imageType) {
		case "image/gif":
	  		imagegif($newImage,$thumb_image_name); 
			break;
      	case "image/pjpeg":
		case "image/jpeg":
		case "image/jpg":
	  		imagejpeg($newImage,$thumb_image_name,90); 
			break;
		case "image/png":
		case "image/x-png":
			imagepng($newImage,$thumb_image_name);  
			break;
    }
	chmod($thumb_image_name, 0777);
	return $thumb_image_name;
}
//You do not need to alter these functions
function getHeight($image) {
	$size = getimagesize($image);
	$height = $size[1];
	return $height;
}
//You do not need to alter these functions
function getWidth($image) {
	$size = getimagesize($image);
	$width = $size[0];
	return $width;
}
function Fget_admin_folder()
  	{
		$CI =& get_instance();
		return $CI->config->item('system_ap_admin_folder');
  	}