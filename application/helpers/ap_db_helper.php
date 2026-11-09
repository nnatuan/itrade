<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

function dbset_cookie($str_cookie_name, $str_cookie_value) 
	{
		$obj_helper =& get_instance();
		$obj_helper->load->database();
			
		// Xac dinh cac thong tin tu thu vien session
		$num_nid_session		= Fget_userdata('session_working');
		$num_nid_user 			= Fget_userdata('session_nid_user');
			
		if ($num_nid_user == 0)
		{
			//
			// Truong hop la khach, dung sessionid de xac dinh thong tin cookie
			//
			$obj_helper->db->where('cid_session',$num_nid_session);
			$obj_helper->db->where('ckey',$str_cookie_name);
			$obj_result = $obj_helper->db->get(Fget_ap_table2('tcookie'));
			if ($obj_result->num_rows() >= 1)
			{
				//
				// Truong hop ton tai dong thong tin cookie tuong ung
				//
				$arr_data =	array(								
					'cvalue' 			=> $str_cookie_value,
					);
				$obj_helper->db->where('cid_session',$num_nid_session);
				$obj_helper->db->where('ckey',$str_cookie_name);	
				$obj_helper->db->update(Fget_ap_table2('tcookie'), $arr_data);
			}
			else
			{
				//
				// Truong hop ton tai dong thong tin cookie tuong ung
				//
				$arr_data =	array(								
					'cid_session' 		=> $num_nid_session,
					'nid_user' 			=> 0,
					'ckey' 				=> $str_cookie_name,
					'cvalue' 			=> $str_cookie_value,
					'cstatus' 			=> 1,
					);
				$obj_helper->db->where('cid_session',$num_nid_session);
				$obj_helper->db->where('ckey',$str_cookie_name);	
				$obj_helper->db->insert(Fget_ap_table2('tcookie'), $arr_data);
			}
		}	
		else
		{
			// Truong hop la thanh vien, dung nid_user de xac dinh thong tin cookie
			$obj_helper->db->where('nid_user',$num_nid_user);
			$obj_helper->db->where('ckey',$str_cookie_name);
			$obj_result = $obj_helper->db->get(Fget_ap_table2('tcookie'));
			if ($obj_result->num_rows() >= 1)
			{
				// Truong hop ton tai dong thong tin cookie tuong ung
				$arr_data =	array(								
					'cvalue' 			=> $str_cookie_value,
					);
				$obj_helper->db->where('nid_user',$num_nid_user);
				$obj_helper->db->where('ckey',$str_cookie_name);	
				$obj_helper->db->update(Fget_ap_table2('tcookie'), $arr_data);
			}
			else
			{
				// Truong hop ton tai dong thong tin cookie tuong ung
				$arr_data =	array(								
					'cid_session' 		=> $num_nid_session,
					'nid_user' 			=> $num_nid_user,
					'ckey' 				=> $str_cookie_name,
					'cvalue' 			=> $str_cookie_value,
					'cstatus' 			=> 1,
					);
				$obj_helper->db->where('nid_user',$num_nid_session);
				$obj_helper->db->where('ckey',$str_cookie_name);	
				$obj_helper->db->insert(Fget_ap_table2('tcookie'), $arr_data);
			}
		}
	}


function dbget_cookie($str_cookie_name)
{
	$obj_helper =& get_instance(); 	
	$obj_helper->load->database();
	// Xac dinh cac thong tin tu thu vien session
	$num_nid_session		= Fget_userdata('session_working');
	$num_nid_user 			= Fget_userdata('session_nid_user');
	
	if ($num_nid_user == 0)
	{	
		//
		// Truong hop la khach, dung sessionid de xac dinh cookie.
		// Trong truong hop khong co thi tra ve gia tri rong.
		//
		$obj_helper->db->where('cid_session',$num_nid_session);
		$obj_helper->db->where('ckey',$str_cookie_name);
		$obj_result = $obj_helper->db->get(Fget_ap_table2('tcookie'));
		if ($obj_result->num_rows() >= 1)
		{
			$obj_row = $obj_result->row_array();
			return $obj_row['cvalue'];
		}
		else
		{
			return '';
		}			
	}
	else
	{
		// Truong hop la khach, dung sessionid de xac dinh cookie.
		// Trong truong hop khong co thi tra ve gia tri rong.
		// Truong hop la khach, dung sessionid de xac dinh cookie.
		// Trong truong hop khong co thi tra ve gia tri rong.
		$obj_helper->db->where('nid_user',$num_nid_user);
		$obj_helper->db->where('ckey',$str_cookie_name);
		$obj_result = $obj_helper->db->get(Fget_ap_table2('tcookie'));
		if ($obj_result->num_rows() >= 1)
		{
			$obj_row = $obj_result->row_array();
			return $obj_row['cvalue'];
		}
		else
		{
			return '';
		}
	}
}


//get indentity
function dbget_identity()
	{
		$obj_helper =& get_instance(); 	
		$obj_helper->load->database();
		
		$str_query = 'SELECT @@IDENTITY as identity' ;
		$obj_result = $obj_helper->db->query($str_query);
		foreach ($obj_result->result() as $row)
		   {
			  return $row->identity;
		   }	
	}

function dbget_current_date()
	{
		$obj_helper =& get_instance(); 	
		$obj_helper->load->database();
		
		$str_query = 'SELECT CURRENT_DATE() AS system_date' ;		
		$obj_result = $obj_helper->db->query($str_query);
		
	   	foreach ($obj_result->result() as $row)
			  return $row->system_date;
	}


function fbcheck_exists_key_addnew($str_table_name, $str_field_name, $str_field_value)
	{
		$obj_helper =& get_instance(); 	
		$obj_helper->load->database();
		
		// Luu y cach su dung thu vien ham DB va cach khai bao menh de where.
		$obj_helper->db->where($str_field_name,$str_field_value);
		$obj_result = $obj_helper->db->get(Fget_ap_table($str_table_name));
		if ($obj_result->num_rows() <= 0)
			return  TRUE;
					
		// return false neu thong tin hop le.
		return FALSE; 		
	}

//
//
//	
function fbcheck_exists_key_update($str_table_name, $str_field_name, $str_field_value, $str_nid)
	{
		$obj_helper =& get_instance(); 	
		$obj_helper->load->database();
		
		$str_db_value='';
		// truy xuat du lieu trong db theo ID.
		// xac dinh gia tri key theo truong.
		$obj_helper->db->where($str_field_name,$str_field_value);
		$obj_result = $obj_helper->db->get(Fget_ap_table($str_table_name));
		if ($obj_result->num_rows() <= 0)
			return  TRUE;
		else
		{
			$obj_row = $obj_result->row_array();			
			$str_db_value = $obj_row['nid'];
			
			if (trim($str_db_value)==trim($str_nid))
				return TRUE;
			else			
				return FALSE;	
		}
	}


function dbget_obj_from_tablename($tableviewname='')
	{
		$obj_helper =& get_instance(); 	
		$obj_helper->load->database();
		
		// Xac dinh ten truong can hien thi theo language dang su dung.
		$field_name = Fget_userdata('session_user_language');
		
		$str_query  = 'SELECT nid as nid, ';
		$str_query .= $field_name . ' as cvalue  ';
		$str_query .= ' FROM ' . Fget_ap_table($tableviewname). ' ' ;
		$str_query .= ' order by nid  ';
				
		$obj_result = $obj_helper->db->query($str_query);
		return $obj_result->result_array();	   	
	}
	

function dbget_obj_month_list()
	{
		return dbget_obj_from_tablename('vmonth');
	}	


function dbget_obj_use_status_list()
	{
		return dbget_obj_from_tablename('vusestatus');		
	}


function dbcount_img_product($nid_product)
	{
		$obj_helper =& get_instance(); 	
		$obj_helper->load->database();
		$obj_helper->db->where('nid_products',$nid_product);
		$obj_result = $obj_helper->db->get(Fget_ap_table('timage_products'));
		return $obj_result->num_rows();		
	}	

function dbcount_img_work($nid_work)
	{
		$obj_helper =& get_instance(); 	
		$obj_helper->load->database();
		$obj_helper->db->where('nid_works',$nid_work);
		$obj_result = $obj_helper->db->get(Fget_ap_table('timage_works'));
		return $obj_result->num_rows();		
	}	

function dbcount_comment_news($nid_news)
	{
		$obj_helper =& get_instance(); 	
		$obj_helper->load->database();
		$obj_helper->db->where('nid_news',$nid_news);
		$obj_result = $obj_helper->db->get(Fget_ap_table('tcomment'));
		return $obj_result->num_rows();		
	}

function gen_xml_category($nid_news)
	{
		$nid_cat	= '';
		$nid_user	= '';
		$username	= '';
		$count_news	= '';
		$cat_news	= '';
		
		$obj_helper =& get_instance(); 	
		$obj_helper->load->database();
		
		//Get nid cat news from nid news
		$obj_helper->db->where('nid',$nid_news);
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tnews')); 
		$obj_results 	= $obj_result->result_array();
		
		foreach($obj_results as $data):
			$nid_cat	= $data['nid_cat_news'];
			$nid_user	= $data['niduser01'];
		endforeach;
		
		//Return name category
		$obj_helper->db->where('nid',$nid_cat);
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tcat_news')); 
		$obj_results 	= $obj_result->result_array();
		
		foreach($obj_results as $data):
			$cat_news	= $data['ccat_news'];
		endforeach;
		
		//Count quantity news result
		$obj_helper->db->where('nid_cat_news',$nid_cat);
		$obj_helper->db->from(Fget_ap_table('tnews'));
		$count_news	= $obj_helper->db->count_all_results();
		
		// Query array news
		$str_query 	 = ' SELECT ctitle, cshort_content, cimage_iphone, nid, ddate01, niduser01 ';
		$str_query 	.= ' FROM '.Fget_ap_table('tnews') ;
		$str_query 	.= ' WHERE nid_cat_news= '.$nid_cat;
		$str_query 	.= ' AND nstatus = 1 ';
		$str_query 	.= ' ORDER BY ddate01 desc, nid desc';	
		$obj_result = $obj_helper->db->query($str_query);  
		$obj_result	= $obj_result->result_array();     
		
		// Get infomation user by id
		$user		= Obj_get_user_datarow($nid_user);
		$nid_user	= $user['cuserid'];
		
		// create a new XML document
		$doc = new DomDocument('1.0','UTF-8');
		
		// add root node
		$root = $doc->createElement('CATEGORY');
		$root->setAttribute('number_articles', $count_news);
		$root->setAttribute('name', $cat_news);
		$root = $doc->appendChild($root);
		
		foreach($obj_result as $data):
		// add node for each row
			$occ = $doc->createElement('ARTICLE');
			$occ = $root->appendChild($occ);
			
			//
			$child = $doc->createElement('title');
			$child = $occ->appendChild($child);
			
		 	$value = $doc->createCDATASection($data['ctitle']);
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('introtext');
			$child = $occ->appendChild($child);
			
			$cshort_content	= trim(cleanText(strip_tags($data['cshort_content'])));
			$cshort_content	= preg_replace( '/&nbsp;/', ' ', $cshort_content );
			$cshort_content	= str_replace( '<p>', ' ', $cshort_content );
			$cshort_content	= str_replace( '</p>', ' ', $cshort_content );
			$cshort_content	= str_replace( '\n', ' ', $cshort_content );
		 	$value = $doc->createCDATASection(str_replace("<br />", "", Fstr_limit($cshort_content,200,'...')));
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('url_image');
			$child = $occ->appendChild($child);
			
			$url_image	= '';
			if($data['cimage_iphone'] != '')
				$url_image	= Fstr_replace('admin/','',base_url()).'upload/ios/'.$data['cimage_iphone'];
			else
				$url_image	= Fstr_replace('admin/','',base_url()).'upload/ios/no_image.jpg';
			
		 	$value = $doc->createCDATASection($url_image);
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('id');
			$child = $occ->appendChild($child);
			
		 	$value = $doc->createCDATASection($data['nid']);
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('date');
			$child = $occ->appendChild($child);
			
		 	$value = $doc->createCDATASection($data['ddate01']);
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('author');
			$child = $occ->appendChild($child);
			
		 	$value = $doc->createCDATASection($nid_user);
			$value = $child->appendChild($value);
			
		endforeach;
		
		// get completed xml document
		$xml_string = $doc->saveXML();
		$cat_news	= filter_file_string($cat_news, '_');
		$doc->save('../xml/categories/category_'.$cat_news.'.xml');
	}	


function gen_xml_article($nid_news)
	{
		$nid_user01	= '';
		$username01	= '';
		$nid_user02	= '';
		$username02	= '';
		$count_news	= '';
		
		$obj_helper =& get_instance(); 	
		$obj_helper->load->database();
		
		//Get nid cat news from nid news
		$obj_helper->db->where('nid',$nid_news);
		$obj_result 	= $obj_helper->db->get(Fget_ap_table('tnews')); 
		$obj_news	 	= $obj_result->result_array();
		
		foreach($obj_news as $data):
			$nid_user01	= $data['niduser01'];
			$nid_user02	= $data['niduser02'];
		endforeach;   
		
		// Get infomation user by id
		$user01		= Obj_get_user_datarow($nid_user01);
		if(isset($user01) && count($user01)>0)
			$username01	= $user01['cuserid'];
		
		$user02		= Obj_get_user_datarow($nid_user02);
		if(isset($user02) && count($user02)>0)
			$username02	= $user02['cuserid'];
		
		// create a new XML document
		$doc = new DomDocument('1.0','UTF-8');
		
		// add root node xml
		$root = $doc->createElement('jos_content');
		$root = $doc->appendChild($root);
		
		foreach($obj_news as $data):
		// add node for each row
			
			// id
			$child = $doc->createElement('id');
			$child = $root->appendChild($child);
			
			$value = $doc->createCDATASection($data['nid']);
			$value = $child->appendChild($value);
			
			// title
			$child = $doc->createElement('title');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection($data['ctitle']);
			$value = $child->appendChild($value);
			
			// alias
			$child = $doc->createElement('alias');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection(filter_file_string($data['ctitle'],'-'));
			$value = $child->appendChild($value);
			
			// title alias
			$child = $doc->createElement('title_alias');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection('');
			$value = $child->appendChild($value);
			
			// introtext
			$child = $doc->createElement('introtext');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection(cleanText($data['cshort_content']));
			$value = $child->appendChild($value);
			
			// fulltext
			
			$pattern = "/height=\"[0-9]*\"/";
			$content = preg_replace($pattern, "", $data['ccontent']);
			$pattern = "/width=\"[0-9]*\"/";
			$content = preg_replace($pattern, "", $content);
			$content = preg_replace("/nowrap=\"nowrap\"/", "", $content);
			$content = str_replace('<td', '<td style="color:#ccc;font-size:10pt;"', $content);
			//echo $string;
			
			$child = $doc->createElement('fulltext');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection(replace_content($content));
			$value = $child->appendChild($value);
			
			// state
			$child = $doc->createElement('state');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection($data['nstatus']);
			$value = $child->appendChild($value);
			
			// sectionid
			$child = $doc->createElement('sectionid');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection($data['nid_section_news']);
			$value = $child->appendChild($value);
			
			// mask
			$child = $doc->createElement('mask');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection(0);
			$value = $child->appendChild($value);
			
			// catid
			$child = $doc->createElement('catid');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection($data['nid_cat_news']);
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('created');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection($data['ddate01']);
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('created_by');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection($username01);
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('created_by_alias');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection($nid_user01);
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('modified');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection($data['ddate02']);
			$value = $child->appendChild($value);
			
			
			//
			$child = $doc->createElement('modified_by');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection($nid_user02);
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('checked_out');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection(0);
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('checked_out_time');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection('0000-00-00 00:00:00');
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('publish_up');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection($data['ddate02']);
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('publish_down');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection('0000-00-00 00:00:00');
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('images');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection('');
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('urls');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection('');
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('attribs');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection('');
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('version');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection(1);
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('parentid');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection(0);
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('ordering');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection($data['cindex']);
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('metakey');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection('');
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('metadesc');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection('');
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('access');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection(0);
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('hits');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection($data['nhit']);
			$value = $child->appendChild($value);
			
			//
			$child = $doc->createElement('metadata');
			$child = $root->appendChild($child);
			
		 	$value = $doc->createCDATASection('');
			$value = $child->appendChild($value);
			
		endforeach;
		
		// get completed xml document
		$xml_string = $doc->saveXML();
		//$cat_news	= filter_file_string($nid_news);
		
		$doc->save('../xml/articles/articles_news_'.$nid_news.'.xml');
	}		
	
	
function filter_file_string( $str , $key)
	{
		$str = explode(" ",$str);
		$string = '';
		for($i = 0; $i<count($str); $i++):
			if($i == 0)
				$string = $str[$i];
			else
				$string = $string.$key.$str[$i];
		endfor;
		$string = strtolower($string);
		return $string;
	}
 
function cleanText( $text )
	{
		$text = preg_replace( '/&nbsp;/', '', $text );
		$text = preg_replace( '/&amp;/', '', $text );
		$text = preg_replace( '/&quot;/', '', $text );
		$text = preg_replace( '/&ldquo;/', '', $text );
		$text = preg_replace( '/&rdquo;/', '', $text );
		$text = preg_replace( '/&rsquo;/', '', $text );
		$text = preg_replace( '/&ndash;/', '', $text );
		$text = preg_replace( '/&sdot;/', '', $text );
		$text = preg_replace( '/&sbquo;/', '', $text );
		$text = preg_replace( '/&lsquo;/', '', $text );
		$text = preg_replace( '/&rsquo;/', '', $text );
		$text = preg_replace( '/&shy;/', '', $text );
		$text = preg_replace( '/&prime;/', '', $text );
		$text = preg_replace( '/&Prime;/', '', $text );
		$text = preg_replace( '/&sbquo;/', '', $text );
		$text = preg_replace( '/&sb;/', '', $text );
		$text = str_replace( '?', '', $text );	
		$text = str_replace( '-', '', $text );
		$text = str_replace( ':', '', $text );
		$text = str_replace( '*', '', $text );
		$text = str_replace( ',', '', $text );
		$text = str_replace( "/'/", '', $text );
        $text = str_replace( "/’/", '', $text );
		$text = preg_replace( '/â€&trade;/', '', $text );
		$text = preg_replace( '/â€˜/', '', $text );
		return $text;
	}
	
function replace_content($text)
	{
		$text	= cleanText($text);
		$text 	= str_replace('<img','<img style="max-width:98%; width:auto; height:auto;"',$text);
		return $text;
	}
