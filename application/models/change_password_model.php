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
 * employee_model class
 *
 * 
 * @package		ap_standard_system
 * @subpackage	models
 * @category	
 * @author		Le Van Huan
 *------------------------------------------------------------------
 */	
class change_password_model extends Model
{
	var $m_table_name = ''; // ten table can su dung trong model.
	var $m_view_name='';	// ten view can su dung trong model.
/**
 *-------------------------------------------------------------------
 * @creator 		: Hoang Minh An - an_hm87@tokaban.com
 * @finished date	: 2009/05/08
 * @description		: Ham khoi tao
 * @access	        : public
 * 
 * @param string	: None
 * 					: 
 * @return string	: None
 *-------------------------------------------------------------------
 * @editor   	    : Hoang Minh An - an_hm87@tokaban.com
 * @finished date	: 2009/11/11
 * @editing content	: 
 *-------------------------------------------------------------------
 */		
function change_password_model() 
	{	
		parent::Model();
		$this->m_table_name = Fget_ap_table('tuser');
		$this->m_view_name 	= Vuser_view();
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
function update_bynid($num_nid, $arr_data)
	{
		$this->db->where('nid', $num_nid);
		$this->db->update($this->m_table_name, $arr_data);
	}
//
//check password khi doi mat khau, neu ton tai thi cho doi
//
function check_password_user($num_nid,$password)
	{
		$str_query = ' SELECT * FROM '.$this->m_view_name;
		$str_query = $str_query . ' WHERE nid = "'.$num_nid. '" AND cpassword = "'.$password . '" ';
		$obj_result = $this->db->query($str_query);  
		return $obj_result->num_rows();
	}

/**
 |====================================================================
 | DANH SACH CAC HAM DINH NGHIA THEM
 |====================================================================
 */
	
	

}
