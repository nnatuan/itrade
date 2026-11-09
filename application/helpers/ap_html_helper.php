<?php if (!defined('BASEPATH')) exit('No direct script access allowed');
		
function Fget_menu_html11($str_niduser)
	{	
														
		$html_menu_return ='';
		$html_menu_item ='';
		$li_tag = 0; 
		$level_tag = 0;
		
		$cid_index_01 = ''; 
		$cfunction = '';
		$cicon_name = '';
		$cmenu_01 = ''; 
		$nid_01 = 0;
		$nid_parent_01 = 0;
		
		$str_id_list='';
		
		//
		//  Thu nghiem trong truong hop khong co DB.
		//		
		
		$html_menu_return = 		'<li>';
		$html_menu_return .= 			'<a href="#"> Hệ thống </a>'; 
		$html_menu_return .= 			'<ul>';
		
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="#"> DM hệ thống </a>';
		$html_menu_return .= 					'<ul>';
		$html_menu_return .= 						'<li>';
		$html_menu_return .= 							'<a href="'.base_url().'index.php/do_department_listview"> DM. Cơ cấu tổ chức </a>';
		$html_menu_return .= 						'</li>';		
		$html_menu_return .= 						'<li>';
		$html_menu_return .= 							'<a href="'.base_url().'index.php/do_employee_listview"> DM. nhân viên </a>';
		$html_menu_return .= 						'</li>';
		$html_menu_return .= 						'<li>';
		$html_menu_return .= 							'<a href="'.base_url().'index.php/do_position_listview"> DM. Chức vụ </a>';
		$html_menu_return .= 						'</li>';
		$html_menu_return .= 						'<li>';
		$html_menu_return .= 							'<a href="'.base_url().'index.php/do_department_group_listview"> DM. Kênh báo cáo </a>';
		$html_menu_return .= 						'</li>';


		$html_menu_return .= 					'</ul>';
		$html_menu_return .= 				'</li>';

		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="#"> Phân quyền </a>';
		$html_menu_return .= 					'<ul>';
		$html_menu_return .= 						'<li>';
		$html_menu_return .= 							'<a href="'.base_url().'index.php/do_menu_permission"> Phân quyền menu chức năng </a>';
		$html_menu_return .= 						'</li>';
		$html_menu_return .= 						'<li>';
		$html_menu_return .= 							'<a href="'.base_url().'index.php/do_department_permission"> Phân nhóm tài khoản theo đơn vị </a>';
		$html_menu_return .= 						'</li>';
		$html_menu_return .= 					'</ul>';
		$html_menu_return .= 				'</li>';

		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_change_password"> Đổi mật khẩu </a>';
		$html_menu_return .= 				'</li>';
		$html_menu_return .= 			'</ul>';
		$html_menu_return .= 		'</li>';
//----------
//		$html_menu_return .= 		'<li>';
//		$html_menu_return .= 			'<a href="#"> Danh mục </a>';
//		$html_menu_return .= 			'<ul>';
//		$html_menu_return .= 				'<li>';
//		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_city_listview"> DM tỉnh thành </a>';
//		$html_menu_return .= 				'</li>';
//		$html_menu_return .= 				'<li>';
//		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_district_listview"> DM quận huyện </a>';
//		$html_menu_return .= 				'</li>';
//
//		$html_menu_return .= 				'<li>';
//		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_ward_listview"> DM phường xã </a>';
//		$html_menu_return .= 				'</li>';
//
//		$html_menu_return .= 				'<li>';
//		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_street_listview"> DM tên đường </a>';
//		$html_menu_return .= 				'</li>';
//
//		$html_menu_return .= 				'<li>';
//		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_store_type_listview"> DM Loại Cửa hàng - điểm bán </a>';
//		$html_menu_return .= 				'</li>';
//		$html_menu_return .= 				'<li>';
//		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_store_listview"> DM Cửa hàng - điểm bán  </a>';
//		$html_menu_return .= 				'</li>';
//		$html_menu_return .= 				'<li>';
//		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_supplier_listview"> DM Nhà Cung Cấp </a>';
//		$html_menu_return .= 				'</li>';
//		
//		$html_menu_return .= 				'<li>';
//		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_tool_listview"> DM công cụ dụng cụ </a>';
//		$html_menu_return .= 				'</li>';
///*		
//		$html_menu_return .= 				'<li>';
//		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_simcard_listview"> DM sim đa năng </a>';
//		$html_menu_return .= 				'</li>';
//		$html_menu_return .= 				'<li>';
//		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_unit_listview"> DM đơn vị tính </a>';
//		$html_menu_return .= 				'</li>';
//
//		$html_menu_return .= 				'<li>';
//		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_product_listview"> DM hàng hoá </a>';
//		$html_menu_return .= 				'</li>';*/
//		$html_menu_return .= 			'</ul>';
//		$html_menu_return .= 		'</li>';
/*//-----------------------		
		$html_menu_return .= 		'<li>';
		$html_menu_return .= 			'<a href="#"> Quản lý </a>';
		$html_menu_return .= 			'<ul>';
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_in_out_tool_listview"> Phiếu nhập xuất CCDC </a>';		
		$html_menu_return .= 				'</li>';
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="#"> Phân bổ Cửa hàng-Điểm bán </a>';		
		$html_menu_return .= 				'</li>';
		
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_tool_warehouse_listview"> Quản lý kho công cụ dụng cụ </a>';		
		$html_menu_return .= 				'</li>';
		
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="#"> Phân bổ công cụ dụng cụ </a>';		
		$html_menu_return .= 				'</li>';
		
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="#"> Kiểm duyệt nghiệp vụ </a>';
		$html_menu_return .= 					'<ul>';	
		$html_menu_return .= 						'<li>';	
		$html_menu_return .= 							'<a href="#"> KD - Phiếu nhập xuất CCDC </a>';
		$html_menu_return .= 						'</li>';
		$html_menu_return .= 						'<li>';	
		$html_menu_return .= 							'<a href="#"> KD - Hoá đơn đặt hàng </a>';
		$html_menu_return .= 						'</li>';
		$html_menu_return .= 						'<li>';	
		$html_menu_return .= 							'<a href="#"> KD - Hoá đơn bán hàng </a>';
		$html_menu_return .= 						'</li>';
		$html_menu_return .= 						'<li>';	
		$html_menu_return .= 							'<a href="#"> KD - Phiếu đăng ký sử dụng Sim đa năng </a>';
		$html_menu_return .= 						'</li>';
		$html_menu_return .= 					'</ul>';	
		$html_menu_return .= 				'</li>';
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="#"> Kiểm duyệt phát sinh ngày </a>';
		$html_menu_return .= 					'<ul>';	
		$html_menu_return .= 						'<li>';	
		$html_menu_return .= 							'<a href="#"> KD - Phiếu xử lý vi phạm sim đa năng </a>';
		$html_menu_return .= 						'</li>';
		$html_menu_return .= 						'<li>';	
		$html_menu_return .= 							'<a href="#"> KD - Phiếu Doanh thu ngày của các đối thủ cạnh tranh </a>';
		$html_menu_return .= 						'</li>';
		$html_menu_return .= 						'<li>';	
		$html_menu_return .= 							'<a href="#"> KD - Báo cáo kết quả chăm sóc cửa hàng điểm bán </a>';
		$html_menu_return .= 						'</li>';
		$html_menu_return .= 						'<li>';	
		$html_menu_return .= 							'<a href="#"> KD - Báo cáo tình trạng sử dụng hình ảnh </a>';
		$html_menu_return .= 						'</li>';
		$html_menu_return .= 						'<li>';	
		$html_menu_return .= 							'<a href="#"> KD - Phiếu tổng hợp chương trình khuyễn mãi của ĐT-CT </a>';
		$html_menu_return .= 						'</li>';		
		
		$html_menu_return .= 					'</ul>';		
		$html_menu_return .= 				'</li>';
		$html_menu_return .= 			'</ul>';
		$html_menu_return .= 		'</li>';*/
		
//-----------

	//	$html_menu_return .= 		'<li>';
//		$html_menu_return .= 			'<a href="#"> Phát sinh ngày </a>';
//		$html_menu_return .= 			'<ul>';
//		$html_menu_return .= 				'<li>';
//		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_reval_promotion_listview"> Phiếu tổng hợp chương trình khuyễn mãi của ĐT-CT </a>';
//		$html_menu_return .= 				'</li>';
//		$html_menu_return .= 				'<li>';
//		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_store_care_result_listview"> Phiếu kết quả chăm sóc cửa hàng điểm bán </a>';
//		$html_menu_return .= 				'</li>';
//		$html_menu_return .= 				'<li>';
//		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_store_tool_inventory_listview"> Phiếu hiện trạng sử dụng Hình ảnh, CCDC cửa hàng điểm bán </a>';
//		$html_menu_return .= 				'</li>';

		
		/*$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="#"> Phiếu đăng ký sử dụng Sim đa năng </a>';		
		$html_menu_return .= 				'</li>';
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_solve_vialated_sim_listview"> Phiếu xử lý vi phạm sim đa năng </a>';		
		$html_menu_return .= 				'</li>';
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_order_bill_listview"> Hoá đơn đặt hàng </a>';		
		$html_menu_return .= 				'</li>';
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_sale_bill_listview"> Hoá đơn bán hàng </a>';		
		$html_menu_return .= 				'</li>';
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_reval_revenue_listview"> Phiếu Doanh thu ngày của các đối thủ cạnh tranh </a>';		
		$html_menu_return .= 				'</li>';*/

	//	$html_menu_return .= 			'</ul>';
//		$html_menu_return .= 		'</li>';
//		
//
//		$html_menu_return .= 		'<li>';
//		$html_menu_return .= 			'<a href="#"> Báo cáo - Thống kê </a>';
//		$html_menu_return .= 			'<ul>';
//		$html_menu_return .= 				'<li>';
//		$html_menu_return .= 					'<a href="#"> BC Danh sách Cửa hàng Điểm bán </a>';	
//		$html_menu_return .= 						'<ul>';	
//		$html_menu_return .= 							'<li>';
//		$html_menu_return .= 								'<a href="'.base_url().'index.php/do_rpt_store_tool"> Danh sách CH-ĐB có hình ảnh, CCDC </a>';
//		$html_menu_return .= 							'</li>';
//		$html_menu_return .= 							'<li>';
//		$html_menu_return .= 								'<a href="'.base_url().'index.php/do_rpt_store_no_tool"> Danh sách CH-ĐB không có hình ảnh, CCDC </a>';		
//		$html_menu_return .= 							'</li>';
//		$html_menu_return .= 						'</ul>';
//		$html_menu_return .= 							'<li>';
//		$html_menu_return .= 								'<a href="'.base_url().'index.php/do_rpt_saler1_2"> Báo cáo thông tin hình ảnh theo cửa hàng, điểm bán </a>';		
//		$html_menu_return .= 							'</li>';		
//		$html_menu_return .= 				'</li>';
		
		
		
	/*	
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_rpt_mutifunc_sim_detail"> BC Danh sách Sim đa năng đăng ký hoạt động </a>';		
		$html_menu_return .= 				'</li>';

		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_rpt_revenue_store"> BC Doanh thu Cửa hàng Điểm bán </a>';		
		$html_menu_return .= 				'</li>';
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_rpt_contact_media"> BC Danh sách các điểm bán tiếp xúc truyền thông và bán hàng </a>';		
		$html_menu_return .= 				'</li>';
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_rpt_contact_media_in_day"> BC Danh sách các điểm bán tiếp xúc truyền thông trong ngày </a>';
		$html_menu_return .= 				'</li>';
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="'.base_url().'index.php/do_rpt_solve_vialated_sim"> BC Kết quả xử lý sim đa năng vi phạm </a>';		
		$html_menu_return .= 				'</li>';*/

		$html_menu_return .= 			'</ul>';

		$html_menu_return .= 		'</li>';
		
		$html_menu_return .= 		'<li>';
		$html_menu_return .= 			'<a href="#"> Trợ giúp </a>';
		$html_menu_return .= 			'<ul>';
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="#"> Hướng dẫn sử dụng </a>';		
		$html_menu_return .= 				'</li>';
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="#"> Hỏi đáp - Góp ý </a>';		
		$html_menu_return .= 				'</li>';
		
		$html_menu_return .= 				'<li>';
		$html_menu_return .= 					'<a href="#"> Sơ đồ chức năng </a>';		
		$html_menu_return .= 				'</li>';
		
		$html_menu_return .= 			'</ul>';
		$html_menu_return .= 		'</li>';
		
		return $html_menu_return;
		
	}
 //
 //
 //
function Fgen_html_combobox(	$str_filter=0, $str_name, $str_value=' ', $str_style='', 
								$obj_data, $field_value, $field_option, $submit_mode='', $tabindex='' )
	{
		$str_return = '';
		$str_select_tag='';
		$str_selected_option = '<option selected="selected"  value="'. $str_value . '">';				
		
		if (trim($str_style)=='')
		{
			$str_select_tag = '<select class="form-control" id="'.$str_name.'" ';
		}
		else 
		{
			$str_select_tag = '<select id="'.$str_name.'" style ="'.$str_style.'"';
		}

		// Xu ly tabindex cho combo
		if (trim($tabindex)!='')
		{
			$str_select_tag = $str_select_tag . ' tabindex="' . $tabindex .'" ';
		}
		
		if (trim($submit_mode)=='submit')
		{
			$str_select_tag = $str_select_tag . ' onChange="this.form.submit();" ';
		}		
		
		$str_return = $str_select_tag . ' name = ' . $str_name . '>';
		
		 
		
		if (trim($str_filter)=='')
		{			
			$str_return = $str_return . ' <option value=""> ' . ' ' . '</option>' ;
		}
		
		foreach($obj_data as $data)
		{
			if (trim($str_value) == $data[$field_value])
			{
				$str_return = $str_return . $str_selected_option . $data[$field_option] . '</option>' ;
			}
			else
			{
				$str_return = $str_return . '<option value='.$data[$field_value].'>' . $data[$field_option] . '</option>' ;
			}
		}
		
		$str_return = $str_return . '</select>';
			
		return $str_return;
	}
 
 //
 //
 //
 function Fgen_combo($obj_data, $str_value_field_name, $str_index_field_name, $str_filter=0, $str_name, $str_value='0', $str_style='', $tabindex='', $submit_mode='' )
	{
		$str_return = '';
		$str_select_tag='';
		$str_selected_option = '<option selected="selected" value="'.$str_value.'">';
		
		if (trim($str_style)=='')
		{
			$str_select_tag = '<select style="width:98%" ';
		}
		else
		{
			$str_select_tag = '<select ';
		}
		if (trim($submit_mode)=='submit')
		{
			$str_select_tag = $str_select_tag . ' onChange="this.form.submit();" ';
		}
		// Xu ly tabindex cho combo
		if (trim($tabindex)!='')
		{
			$str_select_tag = $str_select_tag . ' tabindex="' . $tabindex .'" ';
		}

		$str_return = $str_select_tag . 'name = ' . $str_name . '>';
		if (trim($str_filter)=='0')
		{			
			$str_return = $str_return . '<option value="">' . ' ' . '</option>' ;
		}
				
		foreach($obj_data as $data)
		{
			if (trim($str_value) == $data[$str_index_field_name])
			{
				$str_return = $str_return . $str_selected_option . $data[$str_value_field_name] . '</option>' ;
			}
			else
			{
				$str_return = $str_return . '<option value='.$data[$str_index_field_name].'>' . $data[$str_value_field_name] . '</option>' ;
			}
		}
		
		$str_return = $str_return . '</select>';
			
		return $str_return;
	}
//
// Xac dinh thong tin menu theo phan quyen chuc nang
// Luu y chuc nang quyen quan tri, quyen truong phong, quyen nhan vien
// Quyen truong phong la quyen co the xem all cac thong tin mnu. Gan giong nhu quyen admin.
function Fget_menu_html($nid_user)
{
		$obj_helper =& get_instance(); 
		$obj_helper->load->database();
		
		$html_menu_return 	=''; // Bien dung de nhan thong tin tra ve
		$html_menu_item 	=''; // Bien xac dinh thong tin icon cua cac menu khi xuat hien tren man hinh
		
		// Cac bien dieu khien
		$li_tag = 0;
		$level_tag = 0;
		
		$cid_index_01 = '';
		$cfunction = '';
		$cicon_name = '';
		$cmenu_01 = '';
		$nid_01 = 0;
		$nid_parent_01 = 0;
		
		$isadmin = Fget_userdata('session_user_isadmin');
		// Kiem tra thong tin user co phai la admin hay khong.
		if (trim($isadmin)!='3')
			{		
			// Xac dinh mang gia tri menu id co ban.
			// Thong tin duoc xac dinh trong bang du lieu tmenu.
			$str_id_list = '';
			
			$obj_helper->db->where('cbasic','1');
			$obj_result = $obj_helper->db->get(Fget_ap_table('tmenu'));  
			$obj_result = $obj_result->result_array();
			foreach ($obj_result as $obj_row)
				 $str_id_list .= $obj_row['nid'] . ',';
	
			// Xac dinh mang id user duoc quyen truy cap.
			// Chon nhung menu id co nid_function user co quyen truy cap
			$obj_helper->db->where('nid_user',$nid_user);
			$obj_result = $obj_helper->db->get(Fget_ap_table('tuser_menu'));  
			$obj_result = $obj_result->result_array();
			foreach ($obj_result as $obj_row)
				 $str_id_list .= $obj_row['nid_menu'] . ',';
			
			// Xac dinh thong tin chuoi index tuong ung 
			// Xac dinh danh sach menu thoa dieu kien mang id tuong ung.
			$str_id_list = substr($str_id_list, 0, strlen(trim($str_id_list))-1);
			
			$sql_string = ' SELECT a.*, b.cfunction ';
			$sql_string .= ' FROM  ';
			$sql_string .= ' '. Fget_ap_table('tmenu') .' as a  ,';
			$sql_string .= ' '. Fget_ap_table('tfunction') .' as b  ';
			$sql_string .= ' WHERE  a.cdel=0 ';
			$sql_string .= ' AND a.nid_function = b.nid  ';
			$sql_string .= ' AND a.nid in ('.$str_id_list.') order by a.cindex  ';		
		}
		else
		{
			$sql_string = ' SELECT a.*, b.cfunction ';
			$sql_string .= ' FROM  ';
			$sql_string .= ' '. Fget_ap_table('tmenu') .' as a  ,';
			$sql_string .= ' '. Fget_ap_table('tfunction') .' as b  ';
			$sql_string .= ' WHERE a.cdel=0 ';
			$sql_string .= ' AND a.nid_function = b.nid  order by a.cindex ';
		}
		$menu_root = $obj_helper->db->query($sql_string);
		// CHI THUC HIEN DONG LENH TRONG TRUONG HOP CO DUOC IT NHAT MOT DONG THONG TIN CAN HIEN THI.
		if ($menu_root->num_rows() > 0)
			{
			foreach ($menu_root->result() as $row)
				{
					$cid_index_01 	= $row->cindex;
					$cmenu_01 		= $row->cmenu;
					$nid_01 		= $row->nid;
					$cnode 			= $row->cnode;
					$cicon_name 	= $row->cicon_name;					
					$nid_parent_01 	= $row->nid_parent;				
					$level_tag 		= strlen($cid_index_01)/5;					
					$cfunction 		= $row->cfunction;
					$cmenu_01_lable = $obj_helper->lang->line($cmenu_01);
					// Neu chua dinh nghia trong language, he thong se hien thi thong tin cmenu len man hinh.
					if (trim($cmenu_01) != '')
						if(trim($cmenu_01_lable) == '')
							$cmenu_01_lable = $cmenu_01;

					// iem tra link lien ket cua tung chuc nang menu
					if(trim($cfunction) !='')
						$cfunction = site_url() . '/'.$cfunction;
					else
						$cfunction = '#';
					
					// Kiem tra truong hop phan cach giua cac menu					
					if($cmenu_01 == '')
							$html_menu_item = ' <li class="separator"> <span> </span> ';
					else
						{
							if ($level_tag == 1) // Kiem tra de xac dinh thong root menu. Truong hop can quy dinh class cho tag LI.
								{
									$html_menu_item = ' <li> ';
									$html_menu_item = $html_menu_item . ' <a href="'. $cfunction . ' "> ' . $cmenu_01_lable . ' </a> ';
								    
								}
								else
								{
									if($cnode !='0')
									{
									// Truong hop nay gan nhu khong xay ra.
									$html_menu_item = ' <li> <a '. $cicon_name . ' href="' .  $cfunction  . ' "> ' . $cmenu_01_lable . '</a>';
									}
									else
									{
									// Truong hop nay gan nhu khong xay ra.
									$html_menu_item = ' <li class="node"> <a '. $cicon_name . ' href="' .  $cfunction  . ' "> ' .$cmenu_01_lable . '</a>';				
									}
								}						
						}
					//--------------------------------------------
					if ($li_tag == 0) 
						{
							++$li_tag;
							$html_menu_return = $html_menu_return  . $html_menu_item;															
						}
					else
						{
							if ($level_tag == $li_tag)
							{
								$html_menu_return = $html_menu_return . ' </li> ';
								$html_menu_return = $html_menu_return . $html_menu_item;
							}
							else
							{
								if ($level_tag > $li_tag)
								{
									++$li_tag;	
									$html_menu_return = $html_menu_return . '  <ul>';
									$html_menu_return = $html_menu_return   . $html_menu_item;															
								}
								else
								{
									$html_menu_return = $html_menu_return . ' </li> ';
									while 	($li_tag > $level_tag )					
									{
										$html_menu_return = $html_menu_return . ' </ul> </li> ';
										$li_tag--;
									}									
									$html_menu_return = $html_menu_return  . $html_menu_item;
								}
							}
						}
					}											
				}				
		$html_menu_return = $html_menu_return . ' </li> ';
		while 	($li_tag > 1 )					
			{
				$html_menu_return = $html_menu_return . ' </ul> </li> ';
				$li_tag--;
			}	
		// return object data array
		
		
	
		return  $html_menu_return ;
}	

// dinh nghia them hung_pn89
 function Fgen_html_combobox_disable(	$str_filter=0, $str_name, $str_value=' ', $str_style='', 
								$obj_data, $field_value, $field_option, $submit_mode='', $tabindex='' , $event)
	{
		$str_return = '';
		$str_select_tag='';		
		$disable = '';
		if($event == 'edit' || $event == 'update_edit' || $event == 'edit_trans' || $event == 'update_edit_trans')
		$disable = 'disabled="disabled"';				
		$str_selected_option = '<option selected="selected"  value="'. $str_value . '">';				
		if (trim($str_style)=='')
		{
			$str_select_tag = '<select style="width:98%" '.$disable;
		}
		else
		{
			$str_select_tag = '<select  '.$disable;
		}

		// Xu ly tabindex cho combo
		if (trim($tabindex)!='')
		{
			$str_select_tag = $str_select_tag . ' tabindex="' . $tabindex .'" ';
		}
		
		if (trim($submit_mode)=='submit')
		{
			$str_select_tag = $str_select_tag . ' onChange="this.form.submit();" ';
		}		
		
		$str_return = $str_select_tag . ' name = ' . $str_name . '>';
		
		 
		
		if (trim($str_filter)=='')
		{			
			$str_return = $str_return . ' <option value=""> ' . ' ' . '</option>' ;
		}
		
		foreach($obj_data as $data)
		{
			if (trim($str_value) == $data[$field_value])
			{
				$str_return = $str_return . $str_selected_option . $data[$field_option] . '</option>' ;
			}
			else
			{
				$str_return = $str_return . '<option value='.$data[$field_value].'>' . $data[$field_option] . '</option>' ;
			}
		}
		
		$str_return = $str_return . '</select>';
			
		return $str_return;
	}
