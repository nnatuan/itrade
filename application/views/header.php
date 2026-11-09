<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>	
		<?php	header("Content-Type: text/html; charset=UTF-8"); ?>			
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />					
		<meta name="robots" content="all" />
		<meta name="rating" content="general" />
		<title><?php  echo $this->lang->line('lbl.Application.Name') ?></title>
		<link href="<?php echo base_url().'images/favicon.png' ?>" rel="shortcut icon" type="image/x-icon">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<!-- Bootstrap -->
    <link href="<?php echo base_url(); ?>vendors/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="<?php echo base_url(); ?>vendors/font-awesome/css/font-awesome.min.css" rel="stylesheet">
    <!-- NProgress -->
    <link href="<?php echo base_url(); ?>vendors/nprogress/nprogress.css" rel="stylesheet">
    <!-- iCheck -->
    <link href="<?php echo base_url(); ?>vendors/iCheck/skins/flat/green.css" rel="stylesheet">
	
    <!-- bootstrap-progressbar -->
    <link href="<?php echo base_url(); ?>vendors/bootstrap-progressbar/css/bootstrap-progressbar-3.3.4.min.css" rel="stylesheet">
    <!-- JQVMap -->
    <link href="<?php echo base_url(); ?>vendors/jqvmap/dist/jqvmap.min.css" rel="stylesheet"/>
    <!-- bootstrap-daterangepicker -->
    <link href="<?php echo base_url(); ?>vendors/bootstrap-daterangepicker/daterangepicker.css" rel="stylesheet">

    <!-- Custom Theme Style -->
    <link href="<?php echo base_url(); ?>css/custom.min.css" rel="stylesheet">
	  
	  
		<link href="<?php echo base_url(); ?>css/my_style.css?v<?php echo time(); ?>" rel="stylesheet">
		<link href="<?php echo base_url(); ?>css/responsive_style.css?v<?php echo time(); ?>" rel="stylesheet">
		
		<script type="text/javascript">
		function locdau(str) {  
		  str= str.toLowerCase();  
		  str= str.replace(/à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ/g,"a");  
		  str= str.replace(/è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ/g,"e");  
		  str= str.replace(/ì|í|ị|ỉ|ĩ/g,"i");  
		  str= str.replace(/ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ/g,"o");  
		  str= str.replace(/ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ/g,"u");  
		  str= str.replace(/ỳ|ý|ỵ|ỷ|ỹ/g,"y");  
		  str= str.replace(/đ/g,"d");  
		  str= str.replace(/!|@|%|\^|\*|\(|\)|\+|\=|\<|\>|\?|\/|,|\.|\:|\;|\'| |\"|\&|\#|\[|\]|~|$|_/g,"-"); 
		/* tìm và thay thế các kí tự đặc biệt trong chuỗi sang kí tự - */ 
		  str= str.replace(/-+-/g,"-"); //thay thế 2- thành 1- 
		  str= str.replace(/^\-+|\-+$/g,"");  
		//cắt bỏ ký tự - ở đầu và cuối chuỗi  
		  return str;  
		}   
		</script>
		
		
	</head> 
 <?php //if(!isset($_SESSION['session_nid_user']) || $_SESSION['session_nid_user']=='') redirect(base_url().'index.php/do_logout'); ?>