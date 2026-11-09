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
 * permission_model class
 *
 * 
 * @package		ap_standard_system 
 * @subpackage	models
 * @category	
 * @author		Hoang Minh An 
 *------------------------------------------------------------------
 */	
class permission_model extends Model 
{
//
function permission_model() 
	{	
		parent::Model();
	}
//
// Xac dinh danh sach user theo dieu kien loc
//
function get_user_department($nid_user, $user_name)  
	{	
		$str_query = ' SELECT * FROM  '.Vuser_view();
		$str_query .= ' WHERE  cfullname like "%'.$user_name.'%"'; 
		$str_query .= ' AND nid > 3'; 
		$str_query .= ' ORDER BY  cfullname ';

		$obj_result = $this->db->query($str_query);
		return $obj_result->result_array();
	}
//
//
//
function get_department($nid_user, $nid_department) 
	{	
		// xac dinh thong tin nid_index cua don vi phong ban
		if($nid_department!='')
		{
			$this->db->where('nid',$nid_department);
			$obj_result = $this->db->get(Fget_ap_table('tdepartment'));  
			$obj_result = $obj_result->row_array();			
			$nid_index = $obj_result['nid_index'];
		}
		else
		{
			$nid_index = '';
		}
				
		$str_query = ' SELECT * FROM  '.Vdepartment_view();
		if($nid_index!='')
			$str_query .= ' WHERE  nid_index like "'. $nid_index .'%"';
		
		$str_query .= ' ORDER BY  nid_index ';

		$obj_result = $this->db->query($str_query);
		return $obj_result->result_array();
	}
//
//
//
function get_user_department_result($nid_user, $nid_department) 	
	{		
	$str =' SELECT view.* FROM ';
	$str.=' ( ';
	$str.=' SELECT ';
	$str.=' a.nid 				as nid 	,';
	$str.=' concat(c.cfirstname, " " ,  c.cmiddlename, " " , c.clastname)	as cfullname 	,';
	$str.=' "1" 			 	as isuser 			,';
	$str.=' b.nid_index		 	as nid_index	';
	
	$str.=' FROM ' ;
	$str.='      ' . Fget_ap_table('tuser_department')	. ' as a ,';
	$str.='      ' . Fget_ap_table('tdepartment') 	  	. ' as b ,';
	$str.='      ' . Fget_ap_table('tuser') 			. ' as c ';
	
	$str.=' WHERE  '; 
	$str.='    		a.nid_user=c.nid'; 
	$str.=' AND   	a.nid_department=b.nid'; 
	
	$str.=' UNION ';
	
	$str.=' SELECT ';
	$str.=' a.nid 				as nid 	,';
	$str.=' a.cdepartment		as cfullname 	,';
	$str.=' "0" 			 	as isuser 			,';
	$str.=' a.nid_index		 	as nid_index	';
	
	$str.=' FROM ' ;
	$str.='      ' . Fget_ap_table('tdepartment') 	  	. ' as a ';
	
	$str.=' WHERE  '; 
	$str.='    		a.nid is not null '; 
	$str.=' ) as view ORDER BY view.nid_index , view.isuser';
	$obj_result = $this->db->query($str);
	return $obj_result->result_array();
	
	}

//
//
//
private function checkvalid_user_department_bynid($num_nid)	
	{			
		return 	TRUE;
	}	

//
//
//
function delete_user_department_bynid($num_nid)
	{
		if ($this->checkvalid_user_department_bynid($num_nid) === TRUE)
		{
			$this->db->where('nid_user', $num_nid);
			$this->db->delete( Fget_ap_table('tuser_department'));			
		}
	}
//	
function insert_user_department($arr_data)
	{
		$this->db->insert(Fget_ap_table('tuser_department'), $arr_data);		
	}
//	
function get_department_by_nidindex($nid_index)
	{
		$this->db->where('nid_index',$nid_index);
		$obj_result = $this->db->get(Fget_ap_table('tdepartment'));  
		//return $obj_result->result_array();
		$obj_result = $obj_result->row_array();
		return  $obj_result['nid'];		
	}

function get_menu_by_cindex($cindex)
	{
		$this->db->where('cindex',$cindex);
		$obj_result = $this->db->get(Fget_ap_table('tmenu'));  
		//return $obj_result->result_array();
		$obj_result = $obj_result->row_array();
		return  $obj_result['nid'];		
	}

	
//

function get_user_menu_result($nid_user, $nid_user_filter)
	{
	$str =' SELECT view.* FROM ';
	$str.=' ( ';
	$str.=' SELECT ';
	$str.=' a.nid 				as nid 	,';
	$str.=' 0			as isbasic 	,';
	$str.=' concat(c.cfirstname, " " ,  c.cmiddlename, " " , c.clastname)	as cfullname 	,';
	$str.=' "1" 			 	as isuser 			,';
	$str.=' b.cindex		 	as cindex	';
	
	$str.=' FROM ' ;
	$str.='      ' . Fget_ap_table('tuser_menu')	. ' as a ,';
	$str.='      ' . Fget_ap_table('tmenu') 	  	. ' as b ,';
	$str.='      ' . Fget_ap_table('tuser') 		. ' as c ';
	
	$str.=' WHERE  '; 
	$str.='    		a.nid_user=c.nid'; 
	$str.=' AND		b.cdel=0'; 
	$str.=' AND   	a.nid_menu=b.nid'; 
	if ($nid_user_filter!='')
		$str.=' AND   	c.nid="'.$nid_user_filter.'"'; 
	
	$str.=' UNION ';
	
	$str.=' SELECT ';
	$str.=' a.nid 				as nid 	,';
	$str.=' a.cbasic 					as isbasic 	,';
	$str.=' a.cmenu				as cfullname 	,';
	$str.=' "0" 			 	as isuser 			,';
	$str.=' a.cindex		 	as cindex	';
	
	$str.=' FROM ' ;
	$str.='      ' . Fget_ap_table('tmenu') 	  	. ' as a ';
	
	$str.=' WHERE  '; 
	$str.='    		a.nid is not null AND cmenu<>""'; 
	$str.=' AND		a.cdel=0'; 
	$str.=' ) as view ORDER BY view.cindex , view.isuser';
	$obj_result = $this->db->query($str);
	return $obj_result->result_array();
	}

function delete_user_menu_bynid($num_nid)
	{
		$this->db->where('nid_user', $num_nid);
		$this->db->delete( Fget_ap_table('tuser_menu'));			
	}

function get_menu($nid_user, $cindex)
	{
				
		$str_query = ' SELECT view.* FROM  '.Vmenu_view();
		$str_query .= ' WHERE  view.cmenu <>""';
		if($cindex!='')
			$str_query .= ' AND  view.cindex like "'. $cindex .'%"';
		
		$str_query .= ' ORDER BY  view.cindex ';

		$obj_result = $this->db->query($str_query);
		return $obj_result->result_array();
	}
function insert_user_menu($arr_data)
	{
		$this->db->insert(Fget_ap_table('tuser_menu'), $arr_data);		
	}
	
	
/**
 |====================================================================
 | DANH SACH CAC HAM DINH NGHIA THEM
 |====================================================================
 */
}
