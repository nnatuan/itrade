<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

function Obj_get_menu_list($str_nid_user='') 
	{ 
		$str_sql=' SELECT * FROM ' . Fget_ap_table('tmenu') . ' WHERE cdel=0 AND cmenu<>"" AND cstatus = 1 ORDER BY cindex asc ';
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();		
		//$obj_helper->db->where('cdel','0');
		//$obj_helper->db->where('cmenu<>',$stremty);
		//$obj_helper->db->order_by("cindex", "asc"); 
		//$obj_result 	= $obj_helper->db->get(Fget_ap_table('tmenu')); 
		$obj_result 	= $obj_helper->db->query($str_sql); 
		$obj_results 	= $obj_result->result_array();
		// update thong tin cmenu theo ngon ngu su dung
		
		for ($i=0; $i<count($obj_results); $i++) 
			$obj_results[$i]['cmenu'] = Fview_textindex($obj_results[$i]['cindex']) . $obj_helper->lang->line($obj_results[$i]['cmenu']); 
		
		return 	$obj_results;
	} 
	
 //
 //
 //

function Obj_get_user_type_list($str_nid_user='') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		
		$obj_helper->db->where('cdel','0');
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tuser_type')); 
		$obj_results 	= $obj_result->result_array();
		
		return 	$obj_results;
	}

function Obj_get_user_list($str_nid_user='') 
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		
		$str_query = ' SELECT view.* FROM ' . Vuser_view()  ; 
		$str_query .= ' WHERE nid > 3 ' ; 
		$obj_results = $obj_helper->db->query($str_query);
		$obj_results 	= $obj_results->result_array();
		
		return 	$obj_results;
	}

function Obj_get_user_permission_list($str_nid_user='') 
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		
		$str_query = ' SELECT view.* FROM ' . Vuser_view()  ; 
		$str_query .= ' WHERE nid > 3 ' ; 
		$obj_results = $obj_helper->db->query($str_query);
		$obj_results 	= $obj_results->result_array();
		
		return 	$obj_results;
	}
	    
/**
 *-------------------------------------------------------------------
 * @creator 		: Le Van Huan - huan_lv77@tokaban.com
 * @finished date	: 2009/07/23
 * @description		: Gan gia tri cookie voi mot tu khoa tuong ung
 * 					: 	Yeu cau phai co 2 thong so tokaban session: 
 * 					: 	
 * 					: 	
 * @access	        : public  
 * @param string	: 
 * 					: 
 *
 * @return string	: None
 *-------------------------------------------------------------------
 * @editor   	    : 
 * @finished date	: 
 * @editing content	: 
 *-------------------------------------------------------------------
 */	
function Obj_get_user_name($str_nid_user) 
	{ 
		$obj_helper =& get_instance();
		$obj_helper->load->database();
		
		$str_full_name = 'Guest';
		$obj_helper->db->where('nid',$str_nid_user);
		$obj_result 	= $obj_helper->db->get('tuser');
		$obj_results 	= $obj_result->result_array();
		
		foreach($obj_results as $rows)
			{
				$str_full_name 	.= $rows['cfirstname'] . ' ';
				
				$str_full_name  .= $rows['cmiddlename'] . ' ';
				$str_full_name  .= $rows['clastname'];
			}
		return 	$str_full_name;
	}
/**
 *-------------------------------------------------------------------
 * @creator 		: Le Van Huan - huan_lv77@tokaban.com
 * @finished date	: 2009/07/23
 * @description		: Gan gia tri cookie voi mot tu khoa tuong ung
 * 					: 	Yeu cau phai co 2 thong so tokaban session: 
 * 					: 	
 * 					: 	
 * @access	        : public 
 * @param string	: 
 * 					: 
 *
 * @return string	: None
 *-------------------------------------------------------------------
 * @editor   	    : 
 * @finished date	: 
 * @editing content	: 
 *-------------------------------------------------------------------
 */	
function Obj_is_user($str_userid, $str_password) 
	{ 
		$obj_helper =& get_instance();
		$obj_helper->load->database();
		
		$str_password = Obj_get_password_encode($str_password);
		// kiem tra userid
		// return 'invalid_userid';
		
		$obj_helper->db->where('cuserid',$str_userid);
		$obj_result 	= $obj_helper->db->get('tuser');
		if ($obj_result->num_rows() <= 0)
			return 'invalid';
			
		
		// kiem tra password	
		// return 'invalid_password';
		$obj_helper->db->where('cpassword',$str_password);
		$obj_result 	= $obj_helper->db->get('tuser');
		$obj_results 	= $obj_result->result_array();		
		if ($obj_result->num_rows() <= 0)
			return 'invalid';
			
		// Kiem tra userid va password	
		// return 'invalid_user_password';		
		$obj_helper->db->where('cstatus','1');
		$obj_helper->db->where('cuserid',$str_userid);
		$obj_helper->db->where('cpassword',$str_password);
		$obj_result 	= $obj_helper->db->get('tuser');
		
		if ($obj_result->num_rows() <= 0)
			return 'invalid';		
		else
			{
				$obj_row = $obj_result->row_array();
				return $obj_row['nid'];
			}
		
	}

function Obj_get_user_datarow($nid) 
	{ 
		$obj_helper =& get_instance();
		$obj_helper->load->database();

		$obj_helper->db->where('nid',$nid);
		$obj_result 	= $obj_helper->db->get('tuser');		
		return  $obj_result->row_array();
	}

//
// Da duoc kiem tra
//
function Obj_get_password_normal()
	{
		//return 'tokabanwithyourpassword';	
		return 'Mật khẩu được bảo vệ';
	}
	
//
// Da kiem tra
//
function Obj_get_password_encode($str_password)
	{
		if(empty($str_password))
			return $str_password;
		else
			return md5($str_password);			
	}

//
// Chua kiem tra duoc, bao loi
// Da duoc kiem tra
//
function Obj_get_encode($str_data)
	{
		return base64_encode(Obj_get_password_normal() . $str_data); 
	}
	
//
// Ham giai ma. 
// Da duoc kiem tra.
//	
function Obj_get_decode($str_data)
	{
		$str_key = Obj_get_password_normal();
		$str_decode = base64_decode($str_data);
		 
		if (strpos($str_key,substr($str_decode,0,strlen($str_key))) === false)
			return '';
			
		return substr($str_decode,strlen($str_key) - strlen($str_decode));
	}

function Obj_get_sec_news() 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tsection_news')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}

//
//
//
function Obj_get_cat_news() 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tcat_news')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}

//
//
//
function Obj_get_cat_news_by_nidsec($nid_sec = '') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		if($nid_sec != '')
			$obj_helper->db->where('nid_section_news',$nid_sec);
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tcat_news')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
//
//
function Obj_get_cat_news_by_nidsec_notnull($nid_sec = '') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		if($nid_sec != '')
			$obj_helper->db->where('nid_section_news',$nid_sec);
		//else
			//$obj_helper->db->where('nid_section_news',0);
		$obj_helper->db->order_by('cindex','asc');
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tcat_news')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}

//
function Obj_get_section_news() 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tsection_news')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}

//
//
//
function Obj_get_tlanguage() 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tlanguage')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
//
//
//Lay ngon ngu loai bo nhung ngon ngu da ton tai

function Obj_get_tlanguage2($arr_idlang) 
	{ 	
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_helper->db->where_not_in('nid',$arr_idlang);
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tlanguage')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
function Obj_get_status_list($arr_idlang) 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_helper->db->where_not_in('nid',$arr_idlang);
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tfaq')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
function Obj_get_group_list($nid = '') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tgroup_product')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}	
function Obj_get_material_product_list($nid = '') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tmaterial_products')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
	
	/*
function Obj_get_cat_product_list($nid_material_products)
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_helper->db->where('nid_material_products',$nid_material_products);
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tcat_products')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
	*/
function Obj_get_cat_product_list($nid_material_products)
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_helper->db->where('nid_material_products',$nid_material_products);
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tcat_products')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}	
//function Obj_get_brand_product_list($nid_cat_products)
function Obj_get_brand_product_list()
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
//		$obj_helper->db->where('nid_cat_products',$nid_cat_products);
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tbrand_products')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}


function Obj_get_material_work_list($nid = '') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tmaterial_works')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}

function Obj_get_cat_work_list($nid = '', $material = '') 
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		if($material != '')
			$obj_helper->db->where('nid_material_works',$material);
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tcat_works')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}

function Obj_get_order_status_list($nid = '') 
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('torder_status')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
function Obj_get_ship_type_list() 
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tship_type')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}	
function Obj_get_order_detail_by_nid_order($nid = '') 
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_helper->db->where('nid_order',$nid);
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('torder_detail')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
function get_news_byid($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * FROM '.Fget_ap_table('tnews');
		$str_query .= ' WHERE nid = '.$nid;			
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array();

	}
function get_product_byid($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * FROM '.Fget_ap_table('tproducts');
		$str_query .= ' WHERE nid = '.$nid;			
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array();

	}
function get_cat_product_byid($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * FROM '.Fget_ap_table('tcat_products');
		$str_query .= ' WHERE nid = '.$nid;			
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array();

	}
function get_sec_product_byid($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * FROM '.Fget_ap_table('tmaterial_products');
		$str_query .= ' WHERE nid = '.$nid;			
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array();

	}

//
function Obj_get_cat_faq() 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tcat_faq')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}

function Obj_get_news() 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tnews')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}

//
function Obj_get_news_byid($nid) 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_helper->db->where('nid',$nid);
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tnews')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}

function Obj_get_function_fronend_list($nid = '') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_helper->db->where('nstatus',1);
		$obj_helper->db->order_by('nid asc'); 
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tfunction_frontend')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}

function Obj_get_cat_news_list_for_menu() 
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
 
		$str_query = ' SELECT a.nid as nid, ';
		$str_query .= ' a.ccat_news as ccat_news, ';
		$str_query .= ' b.csection_news as csection_news';
		$str_query .= ' FROM '.Fget_ap_table('tcat_news').' as a ';
		$str_query .= ' LEFT JOIN '.Fget_ap_table('tsection_news').' as b ON (a.nid_section_news = b.nid) ';	
		$str_query .= ' WHERE a.nid is not null ';		
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->result_array();
	}

function Obj_get_sec_news_list($nid = '') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_helper->db->where('nstatus',1);
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tsection_news')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
	
// Menu frontend
function Obj_get_menu_frontend_list() 
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();		
		$str_sql=' SELECT * FROM ' . Fget_ap_table('tmenu_frontend') . ' WHERE nid is not null AND nstatus = 1 ORDER BY ccat_index asc, nindex asc ';
		$obj_result 	= $obj_helper->db->query($str_sql); 
		$obj_results 	= $obj_result->result_array();
		
		// update thong tin cmenu theo ngon ngu su dung
		
		for ($i=0; $i<count($obj_results); $i++) 
			$obj_results[$i]['cmenu'] = Fview_textindex($obj_results[$i]['ccat_index']) . $obj_results[$i]['cmenu']; 
		
		return 	$obj_results;
	}

function Obj_get_city_list($nid = '') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_helper->db->order_by('ccity','asc');
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tcity')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}


function Obj_get_cat_wood_by_nidsec($nid_sec = '') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		if($nid_sec != '')
			$obj_helper->db->where('nid_section_news',$nid_sec);
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tcat_wood')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
	
function Obj_get_section_wood() 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tsection_wood')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}	
function Obj_get_product_img($nid = '') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_helper->db->where('nid_product',$nid);
		$obj_helper->db->order_by("ddate01", "desc");
		$obj_helper->db->order_by("nid", "desc"); 
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tgallery_detail')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
function Obj_get_news_img($nid = '') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_helper->db->where('nid_product',$nid);
		$obj_helper->db->order_by("ddate01", "desc");
		$obj_helper->db->order_by("nid", "desc"); 
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tnews_gallery_detail')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}

function get_img_by_cat($id_cat){
	
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_helper->db->where('id_cus',$id_cat);
		$obj_helper->db->order_by("nid", "desc");
		$obj_helper->db->limit("5", "0");
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tfiles_detail')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
function get_img_by_product($nid){
	
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_helper->db->where('nid_product',$nid);
		$obj_helper->db->order_by("nid", "desc");
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tproduct_images')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
function Obj_get_code_sale_list($nid = '') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tcode_sale')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
function Obj_get_loai_bds_list($nid = '') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tloai_bds')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}	
function Obj_get_loai_tin_list($nid = '') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tloai_tin')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
function Obj_get_huong_list($nid = '') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('thuong')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
function Obj_get_province_list($nid = '') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tprovince')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
function Obj_get_district_list($nid_province)
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_helper->db->where('nid_province',$nid_province);
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tdistrict')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}		
	
function get_user_byid($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * FROM '.Fget_ap_table('tuser');
		$str_query .= ' WHERE nid = '.$nid;			
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array();

	}	
	function get_user_type_by_id($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * FROM '.Fget_ap_table('tuser_type');
		$str_query .= ' WHERE nid = '.$nid;			
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array();
	}
function get_color_byid($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * FROM '.Fget_ap_table('tcolor');
		$str_query .= ' WHERE nid = '.$nid;			
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array();
	}
function get_gift_by_order($nid_order){
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * FROM '.Fget_ap_table('tgift');
		$str_query .= ' WHERE nid_cart = '.$nid_order;			
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->result_array();
}
function get_news_all(){
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * FROM '.Fget_ap_table('tnews');		
		$str_query .= ' WHERE nstatus=1 ';	
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->result_array();
}
function get_sec_all()
{
	$obj_helper =& get_instance(); 
	$obj_helper->load->database();	
	$str_query = ' SELECT a.* ';
	$str_query .= ' FROM '.Fget_ap_table('tmaterial_products').' as a ';
	$str_query .= ' WHERE a.nstatus=1 ';
	$obj_result = $obj_helper->db->query($str_query);  
	return $obj_result->result_array();
}	
function get_brand_all()
{
	$obj_helper =& get_instance(); 
	$obj_helper->load->database();	
	$str_query = ' SELECT a.* ';
	$str_query .= ' FROM '.Fget_ap_table('tbrand_products').' as a ';
	$str_query .= ' WHERE a.nstatus=1 ';
	$obj_result = $obj_helper->db->query($str_query);  
	return $obj_result->result_array();
}	
function get_cat_by_sec($nid)
{
	$obj_helper =& get_instance(); 
	$obj_helper->load->database();	
	$str_query = ' SELECT a.* ';
	$str_query .= ' FROM '.Fget_ap_table('tcat_products').' as a ';
	$str_query .= ' WHERE a.nstatus=1 ';
	$str_query .= ' AND nid_material_products = '.$nid;
	$obj_result = $obj_helper->db->query($str_query);  
	return $obj_result->result_array();
}	
function get_product_by_cat($nid)
{
	$obj_helper =& get_instance(); 
	$obj_helper->load->database();	
	$str_query = ' SELECT a.* ';
	$str_query .= ' FROM '.Fget_ap_table('tproducts').' as a ';
	$str_query .= ' WHERE a.nstatus=1 ';
	$str_query .= ' AND nid_cat_products = '.$nid;
	$obj_result = $obj_helper->db->query($str_query);  
	return $obj_result->result_array();
}	
function get_product_all()
{
	$obj_helper =& get_instance(); 
	$obj_helper->load->database();	
	$str_query = ' SELECT a.* ';
	$str_query .= ' FROM '.Fget_ap_table('tproducts').' as a ';
	$str_query .= ' WHERE a.nstatus=1 ';
	$obj_result = $obj_helper->db->query($str_query);  
	return $obj_result->result_array();
}	
function get_member_by_id($nid)
{
	$obj_helper =& get_instance(); 
	$obj_helper->load->database();	
	$str_query = ' SELECT a.* ';
	$str_query .= ' FROM '.Fget_ap_table('tmember').' as a ';
	$str_query .= ' WHERE a.nid is not null ';
	$str_query .= ' AND a.nid = "'.$nid.'"';
	$obj_result = $obj_helper->db->query($str_query); 
	return $obj_result->row_array();
}
function get_count_bid_by_product_bid($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * ';
		$str_query .= ' FROM '.Fget_ap_table('tbid').' as a ';
		$str_query .= ' WHERE a.nid is not null ';
		$str_query .= ' AND a.nid_product_bid = "' . $nid . '"';
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->num_rows();
	}
function get_bid_win_by_product_bid($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * ';
		$str_query .= ' FROM '.Fget_ap_table('tbid_win').' as a ';
		$str_query .= ' WHERE a.nid is not null ';
		$str_query .= ' AND a.nid_product_bid = "' . $nid . '"';
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array();
	}
function get_check_subsite($nid = '') 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_helper->db->where('nid_news',$nid);
		//$obj_helper->db->order_by("nid", "desc"); 
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tnews_subsite')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}	
function get_subsite_all() 
	{ 
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tsubsite')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}	
function get_all_loc_banner(){
	
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		$obj_helper->db->order_by("cindex + 0", "asc");
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tlocation_banner')); 
		$obj_results 	= $obj_result->result_array();
		return 	$obj_results;
	}
function get_access_all()
{
	$obj_helper =& get_instance(); 
	$obj_helper->load->database();	
	$str_query = ' SELECT a.*';
	$str_query .= ' FROM '.Fget_ap_table('taccess').' as a ';
	$str_query .= ' WHERE a.nid is not null ';
	$str_query .= ' ORDER BY a.nid_group, a.nid';
	$obj_result = $obj_helper->db->query($str_query); 
	return $obj_result->result_array();
}
function get_flashsale_all()
{
	$obj_helper =& get_instance(); 
	$obj_helper->load->database();	
	$str_query = ' SELECT a.*';
	$str_query .= ' FROM '.Fget_ap_table('tflashsale').' as a ';
	$str_query .= ' WHERE a.nid is not null ';
	//$str_query .= ' ORDER BY a.nid';
	$obj_result = $obj_helper->db->query($str_query); 
	return $obj_result->result_array();
}
function get_flashsale_product($nid)
{
	$obj_helper =& get_instance(); 
	$obj_helper->load->database();	
	$str_query = ' SELECT a.*';
	$str_query .= ' FROM '.Fget_ap_table('tflashsale_product').' as a ';
	$str_query .= ' WHERE a.nid is not null ';
	$str_query .= ' AND a.nid_product = '.$nid;
	$obj_result = $obj_helper->db->query($str_query); 
	return $obj_result->result_array();
}
function get_permission_by_user_type($nid)
{
	$obj_helper =& get_instance(); 
	$obj_helper->load->database();	
	$str_query = ' SELECT a.*';
	$str_query .= ' FROM '.Fget_ap_table('tpermission').' as a ';
	$str_query .= ' WHERE a.nid is not null ';
	$str_query .= ' AND a.nid_user_type = '.$nid;
	$obj_result = $obj_helper->db->query($str_query); 
	return $obj_result->result_array();
}
function get_check_permission($nid_access)
{
	$obj_helper =& get_instance(); 
	$obj_helper->load->database();	
	$str_query = ' SELECT a.nid';
	$str_query .= ' FROM '.Fget_ap_table('tpermission').' as a ';
	$str_query .= ' WHERE a.nid is not null ';
	$str_query .= ' AND a.nid_access = '.$nid_access;
	$str_query .= ' AND a.nid_user_type = '.Fget_userdata('session_user_isadmin');
	
	$obj_result = $obj_helper->db->query($str_query);
	if(isset($obj_result->row_array()['nid']))
		return true;
	return false;
}
function get_config_by_id($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT *';
		$str_query .= ' FROM '.Fget_ap_table('tconfig').' as a ';
		$str_query .= ' WHERE a.nid is not null ';
		$str_query .= ' AND a.nid = '.$nid;
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array();
	}
function get_sec_product_name($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * ';
		$str_query .= ' FROM '.Fget_ap_table('tmaterial_products').' as a ';
		$str_query .= ' WHERE a.nid is not null ';
		$str_query .= ' AND a.nid = "' . $nid . '"';
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array()['cmaterial_products'];
	}	
function get_cat_product_name($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * ';
		$str_query .= ' FROM '.Fget_ap_table('tcat_products').' as a ';
		$str_query .= ' WHERE a.nid is not null ';
		$str_query .= ' AND a.nid = "' . $nid . '"';
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array()['ccat_products'];
	}	
function get_product_name($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * ';
		$str_query .= ' FROM '.Fget_ap_table('tproducts').' as a ';
		$str_query .= ' WHERE a.nid is not null ';
		$str_query .= ' AND a.nid = "' . $nid . '"';
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array()['cproducts'];
	}	
function get_cat_product_id_sec($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * ';
		$str_query .= ' FROM '.Fget_ap_table('tcat_products').' as a ';
		$str_query .= ' WHERE a.nid is not null ';
		$str_query .= ' AND a.nid = "' . $nid . '"';
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array()['nid_material_products'];
	}
function get_order_status_name($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * ';
		$str_query .= ' FROM '.Fget_ap_table('torder_status').' as a ';
		$str_query .= ' WHERE a.nid is not null ';
		$str_query .= ' AND a.nid = "' . $nid . '"';
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array()['corder_status'];
	}	
function get_order_by_code($ccode)
{
	$obj_helper =& get_instance(); 
	$obj_helper->load->database();	
	$str_query = ' SELECT a.nid, a.cfullname, a.cphone, a.ntotal, a.cgiam_gia, a.nid_province, a.nid_district, a.nid_ward, a.caddress';
	$str_query .= ' FROM '.Fget_ap_table('torder').' as a ';
	$str_query .= ' WHERE a.nid is not null ';
	$str_query .= ' AND a.ccode = "' . $ccode . '"';
	$obj_result = $obj_helper->db->query($str_query); 
	return $obj_result->row_array();
}		
function get_order_detail($nid)
{
	$obj_helper =& get_instance(); 
	$obj_helper->load->database();	
	$str_query = ' SELECT a.nid_product, a.cprice, a.nquantity, a.niscolor';
	$str_query .= ' FROM '.Fget_ap_table('torder_detail').' as a ';
	$str_query .= ' WHERE a.nid_order = '.$nid;
	$obj_result = $obj_helper->db->query($str_query); 
	return $obj_result->result_array();
}	
function get_setting_by_user($nid)
{
	$obj_helper =& get_instance(); 
	$obj_helper->load->database();	
	$str_query = ' SELECT a.*';
	$str_query .= ' FROM '.Fget_ap_table('tsetting').' as a ';
	$str_query .= ' WHERE a.nid is not null ';
	$str_query .= ' AND a.nid_user = '.$nid;
	$obj_result = $obj_helper->db->query($str_query); 
	return $obj_result->row_array();
}	
function get_product_by_key($nid_user, $key)
{
	$obj_helper =& get_instance(); 
	$obj_helper->load->database();	
	$str_query = ' SELECT nid, cimage_resize, cproducts, fprice_sale, fprice, cbarcode, ncheck';
	$str_query .= ' FROM '.Fget_ap_table('tproducts').' as a ';
	$str_query .= ' WHERE a.nid is not null ';
	//$str_query .= ' AND niduser01 = '.$nid_user;
	$str_query .= ' AND (a.cproducts like "%'.$key.'%"';
	$str_query .= ' OR a.ccode like "%'.$key.'%")';
	$str_query .= ' LIMIT 0,20 ';
	$obj_result = $obj_helper->db->query($str_query); 
	return $obj_result->result_array();
}
function get_product_color($nid)
{
	$obj_helper =& get_instance(); 
	$obj_helper->load->database();	
	$str_query = ' SELECT *';
	$str_query .= ' FROM '.Fget_ap_table('tcolor').' as a ';
	$str_query .= ' WHERE a.nid is not null ';
	$str_query .= ' AND a.nstatus =	1';
	if($nid !='')
		$str_query .= ' AND a.nid_product = "' . $nid . '"';
	$obj_result = $obj_helper->db->query($str_query);  
	return $obj_result->result_array();
}
function get_customer_by_phone($cphone)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * ';
		$str_query .= ' FROM '.Fget_ap_table('tcustomer').' as a ';
		$str_query .= ' WHERE a.nid is not null ';
		$str_query .= ' AND a.cphone = "' . $cphone . '"';
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array();
	}
function get_field_by_table($table,$id,$field)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * ';
		$str_query .= ' FROM '.Fget_ap_table($table).' as a ';
		$str_query .= ' WHERE a.nid = '.$id;
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array()[$field];
	}	
function get_code_sec($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * ';
		$str_query .= ' FROM '.Fget_ap_table('tmaterial_products').' as a ';
		$str_query .= ' WHERE a.nid is not null ';
		$str_query .= ' AND a.nid = "' . $nid . '"';
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array()['ccode'];
	}
function get_code_cat($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * ';
		$str_query .= ' FROM '.Fget_ap_table('tcat_products').' as a ';
		$str_query .= ' WHERE a.nid is not null ';
		$str_query .= ' AND a.nid = "' . $nid . '"';
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array()['ccode'];
	}	
function get_ward_name($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * ';
		$str_query .= ' FROM '.Fget_ap_table('tward').' as a ';
		$str_query .= ' WHERE a.nid is not null ';
		$str_query .= ' AND a.nid = "' . $nid . '"';
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array()['cname'];
	}	
function get_district_name($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * ';
		$str_query .= ' FROM '.Fget_ap_table('tdistrict').' as a ';
		$str_query .= ' WHERE a.nid is not null ';
		$str_query .= ' AND a.nid = "' . $nid . '"';
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array()['cname'];
	}	
function get_province_name($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT * ';
		$str_query .= ' FROM '.Fget_ap_table('tprovince').' as a ';
		$str_query .= ' WHERE a.nid is not null ';
		$str_query .= ' AND a.nid = "' . $nid . '"';
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array()['cname'];
	}	
function get_qty_by_order($nid)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT sum(nquantity) as qty ';
		$str_query .= ' FROM '.Fget_ap_table('torder_detail').' as a ';
		$str_query .= ' WHERE a.nid_order = "' . $nid . '"';
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->row_array()['qty'];
	}	
function get_trip_by_order_vtp($ccode)
	{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();	
		$str_query = ' SELECT *';
		$str_query .= ' FROM '.Fget_ap_table('ttrip').' as a ';
		$str_query .= ' WHERE a.ORDER_NUMBER = "' . $ccode . '"';
		$obj_result = $obj_helper->db->query($str_query);  
		return $obj_result->result_array();
	}	