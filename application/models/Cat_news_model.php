<?php if (!defined('BASEPATH')) exit('No direct script access allowed'); 

/**
 * =================================================================
 * Tokaban Standard System.
 * CodeIniter Tokaban framework for PHP.
 *
 * @package		: CI-TKB 
 * @author		: Tokaban R&D Team.
 * 				: an_hm87
 * @copyright	: Copyright (c) 2009, Tokaban, Inc.
 * @since		: Version 2.0
 * =================================================================
 */   

/**
 *------------------------------------------------------------------
 * cat_news_model class
 *
 * 
 * @package		ap_standard_system
 * @subpackage	models
 * @category	 
 * @author		Hoang Minh An
 *------------------------------------------------------------------
 */	
class cat_news_model extends CI_Model
{
	var $m_table_name = ''; // ten table can su dung trong model.
	var $m_view_name='';	// ten view can su dung trong model.
/**
 *-------------------------------------------------------------------
 * @creator 		: Hoang Minh An - huan_lv77@tokaban.com
 * @finished date	: 2009/05/08
 * @description		: Ham khoi tao
 * @access	        : public
 * 
 * @param string	: None
 * 					: 
 * @return string	: None
 *-------------------------------------------------------------------
 * @editor   	    : Phan Ngoc Hung - an_hm87@tokaban.com
 * @finished date	: 2009/11/11
 * @editing content	: 
 *-------------------------------------------------------------------
 */	
function __construct() 
	{	
		parent::__construct();
		$this->m_table_name = Fget_ap_table('tcat_news'); // gan ten table su dung trong database cho bien lay table su dung trong model
		$this->m_view_name 	= Vcat_new_view();			 // goi ham trong helper de lay view su dung trong model
	}
	
//
// Luu y cach su dung gia tri tra ve.
// Cach truy xuat gia tri tra ve $obj_row['nid']
function get_byid($nid)
		{
			$this->db->where('nid',$nid);
			$obj_result = $this->db->get($this->m_table_name); 
			return $obj_result->row_array();
		}
		 
//
//
//
function insert($arr_data)
	{
		$this->db->insert($this->m_table_name, $arr_data);		
	}

//
//
//
function update_bynid($num_nid, $arr_data)
	{
		$this->db->where('nid', $num_nid);
		$this->db->update($this->m_table_name, $arr_data);
	}

//
//
//
private function checkvalid_delete($num_nid)	
	{			
		// Kiem tra thong tin store chua duoc su dung trong man hinh cua hang diem ban, bang tstore
		/*$this->db->where('nid',$num_nid);
		$obj_result=$this->db->get(Fget_ap_table('cat_news'));*/
		
		
		// Chi run dong nay neu cac dieu kien kiem tra phia tren khong xay ra.
		return 	TRUE;
	}	

//
//
//
function delete_byid($num_nid) 
	{
		if ($this->checkvalid_delete($num_nid) === TRUE)
		{
			$this->db->where('nid', $num_nid);
			$this->db->delete($this->m_table_name);			
		}
	}

//
//
//		
function get_listview_report($str_where_clause, $str_order_by_clause)	
	{
		$str_query = ' SELECT * FROM  '.$this->m_view_name;
		$str_query = $str_query . ' ' . $str_where_clause . ' ';
		if (trim($str_order_by_clause)!= '')
		{
			$str_query = $str_query . ' order by ' . $str_order_by_clause ;
		}	
		$obj_result = $this->db->query($str_query);
		
		return $obj_result->result_array();
	}
//
/**
 *-------------------------------------------------------------------
 * @creator 		: Hoang Minh An - huan_lv77@tokaban.com
 * @finished date	: 2009/05/08
 * @description		: Xuat du lieu ra excel 
 * @access	        : public
 *
 * @param string	: $report_name    :  ten file excel
 * 					: $data           :  mang du lieu de xuat excel
 *
 * @return string	: 
 *-------------------------------------------------------------------
 * @editor   	    : Phan Ngoc Hung - an_hm87@tokaban.com
 * @finished date	: 2009/12/13
 * @editing content	: 
 *-------------------------------------------------------------------
 */			
function export_excel($report_name,$data)	
	{
		header("Content-type: application/vnd.ms-excel"); 
		header("Content-Disposition: attachment; filename=".$report_name);
		header("Pragma: no-cache");
		header("Expires: 0");
		print ($this->load->view('cat_news_view/ap_cat_news_excel.php',$data));
	}
//
//	
function get_count_listview($str_where_clause)
	{		
		$str_query = ' SELECT nid FROM '.$this->m_view_name;
		$str_query = $str_query . ' ' . $str_where_clause . ' ';
		$obj_result = $this->db->query($str_query);  
		return $obj_result->num_rows();
	}

/**
 *-------------------------------------------------------------------
 * @creator 		: Hoang Minh An- huan_lv77@tokaban.com
 * @finished date	: 2009/011/09
 * @description		: Tra ve tong so dong tu cau lenh sql tuong ung
 * @access	        : public
 *
 * @param string	: $str_where_clause       : menh de where
 * 					: 
 * @return string	: $obj_result->num_rows() : tong so dong
 *-------------------------------------------------------------------
 * @editor   	    : 
 * @finished date	: 
 * @editing content	: 
 *-------------------------------------------------------------------
 */
function get_listview($str_where_clause, $str_order_by_clause, $num_row_per_page, $num_current_page, $num_total_row)
	{		
		$str_query = ' SELECT * FROM  '.$this->m_view_name;
		
		$str_query = $str_query . ' ' . $str_where_clause . ' ';
		
		if (trim($str_order_by_clause)!= '')
		{
			$str_query = $str_query . ' order by ' . $str_order_by_clause . ' ';
		}
		if ($num_total_row > 0)
		{	
			$str_query = $str_query . ' limit '. ($num_current_page -1 )* $num_row_per_page . ' , ' . $num_row_per_page;		
		}
		
		$obj_result = $this->db->query($str_query);  
		return $obj_result->result_array();
	}

/**
 |====================================================================
 | DANH SACH CAC HAM DINH NGHIA THEM
 |====================================================================
 */
function get_new_byid($nid)
	{
		$this->db->where('nid',$nid);
		$obj_result = $this->db->get($this->m_table_name); 
		return $obj_result->row_array();
	}
function get_by_idlang($nid_lang)
	{
		$str_query = ' SELECT * FROM '.$this->m_view_name;
		$str_query = $str_query . ' WHERE nid_language = '.$nid_lang ;
		$obj_result = $this->db->query($str_query);  
			
		return $obj_result->result_array();
	}
	

}
