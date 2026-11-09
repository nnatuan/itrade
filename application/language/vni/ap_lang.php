<?php   if (!defined('BASEPATH')) exit('No direct script access allowed');

/**
 *
 * THONG TIN NGON NGU DUNG CHO PHAN HE THONG 
 *
 */	
 	$lang['lbl.Application.Name']   = 'CMS ADMINISTRATOR ';
	$lang['lbl.Customer.Name']   	= '';
	$lang['lbl.Customer.Address']   = '.';

	$lang['lbl.Developed.Name']   	= '';	
	$lang['lbl.Developed.Address']  = '';
			
	$lang['btn.0000.Save']   		= "Save";
	$lang['btn.0000.Accept'] 		= 'agree';
	$lang['btn.0000.Cancel'] 		= 'Cancel';
	$lang['lbl.0000.Tag']	 		= 'Tags';
	$lang['lbl.0000.DataNotTag']	= 'Data not tags';
	$lang['btn.0000.Update'] 		= 'Update';
	
	$lang['btn.0000.Add']    		= 'Add';
	$lang['btn.0000.Delete'] 		= 'Delete';
	$lang['btn.0000.Edit'] 	 		= 'Edit';
	$lang['btn.0000.Export'] 		= 'Export Excel';
	$lang['btn.0000.Choose'] 		= 'Selete';
	$lang['btn.0000.Filter'] 		= 'Filter';
	$lang['btn.0000.View']   		= 'View';
	$lang['btn.0000.Print']  		= 'Print';

	$lang['lbl.0000.Exit']   		= 'Logout';
	$lang['lbl.0000.RowPerPage']	= 'Row per page';
	$lang['lbl.0000.Date01'] 		= 'Date create';
	$lang['lbl.0000.Date02'] 		= 'Date modifier';
	$lang['lbl.0000.User01'] 		= 'User create';
	$lang['lbl.0000.User02'] 		= 'User modifier';
	
	$lang['lbl.0000.
	Product']	= 'Chọn Sản phẩm';
	$lang['lbl.0000.SelectUnit']	= 'Chọn Đơn vị tính';
	$lang['lbl.0000.Filter']		= 'Filter';
	$lang['lbl.0000.FromDate']		= 'From date';
	$lang['lbl.0000.ToDate']		= 'To date';
	$lang['lbl.0000.BasicPermision'] = 'Basic permission';
	
	$lang['lbl.0000.Yes'] 			= 'Yes';
	$lang['lbl.0000.No'] 			= 'No';
	
	$lang['lbl.0000.message_valid_delete']  = 'Dữ liệu không thể xóa, xin vui lòng kiểm tra lại các thông tin con';
	
	$lang['msg.0000.ErorNotNull'] 			= ' is not null ';

	$lang['msg.0000.ErorDoubleKey'] 		= ' đã tồn tại, vui lòng chọn giá trị khác ';
	$lang['msg.0000.ErorInvalidDate'] 		= ' không đúng kiểu ngày quy định (dd/mm/yyyy)';
	$lang['msg.0000.ErorInvalidYear'] 		= ' Bạn vui lòng nhập thông tin NĂM có 4 ký tự số.';
	$lang['msg.0000.ErorInvalidNumber'] 	= ' Eror Invalid Number';
	$lang['msg.0000.ErorObjectData'] 		= ' Dữ liệu không hợp lệ.';
	
	$lang['msg.0000.ErorObjectIndexData'] 		= ' Bộ tạo khóa tự động bị trùng thông tin, vui lòng chọn giá trị khác.';
	
	$lang['msg.0000.InvalidBeforeDelete'] 	= 'Please select object to operate this function !!!';
	$lang['msg.0000.ConfirmBeforeDelete'] 	= 'Information will be not able to recovered after this !!! Are you sure to do this function?';

	$lang['msg.0000.NotNullValue'] 			= ' Attributes required';
	
/**
 *
 * 	THONG TIN CAC MAN HINH  LOGIN, CONFIRM LOGOUT, CHANGE PASSWORD
 *	Cookie key : 0001
 */
	$lang['lbl.0001.FormTitle'] 			= 'LOGIN';
	$lang['lbl.0001.FormSlogan'] 			= 'Hệ thống chỉ dành cho nhân viên.<br/> Bạn cần có thông tin để đăng nhập. ';
	$lang['lbl.0001.UserName'] 				= ' Username ';
	$lang['lbl.0001.Password'] 				= ' Password ';
	
	$lang['btn.0001.Login']  				= "Login";
	
	$lang['msg.0001.InvalidPassword'] 		= 'Mật khẩu không tồn tại, vui lòng nhập lại.';
	$lang['msg.0001.InvalidUserName'] 		= 'Tài khoản không tồn tại, vui lòng nhập lại.';
	
	$lang['err.0001.unsuccess_login'] 		= 'Unsuccess login';
	$lang['err.0001.err_change_password'] 	= 'Thông tin mật khẩu không đúng';
	
	
	$lang['lbl.0001.FormTitleChangePass'] 	= 'ĐỔI MẬT KHẨU';
	$lang['lbl.0001.old_password'] 			= 'Mật khẩu cũ';
	$lang['lbl.0001.new_password'] 			= 'Mật khẩu mới';
	$lang['lbl.0001.comfirm_password'] 		= 'Xác nhận mật khẩu';
	$lang['err.0001.err_old_password'] 		= 'Mật khẩu cũ không tồn tại';
	$lang['err.0001.err_comfirm_password'] 	= 'Mật khẩu xác nhận không đúng';
	
	$lang['lbl.logout.confirm'] 			= 'Do you sure logout system?';
	$lang['lbl.logout.guide'] 				= 'Press "Logout" to logout the system or press "Cancel" to return to the application.';
	
	
/**
 *
 * THONG TIN NGON NGU DUNG CHO PHAN QUAN LY DANH MUC NHAN VIEN 
 * HUAN_LV77
 */
    
 	$lang['lbl.employee.FormViewTitle'] 	= 'User manager';
	$lang['lbl.employee.FormEditTitle'] 	= 'Edit user';
    $lang['lbl.employee.FormAddTitle']  	= 'Add user'; 
	
	$lang['lbl.employee.ccode']  			= 'Code'; 
	$lang['lbl.employee.cuserid']  			= 'Username'; 
	$lang['lbl.employee.cpassword']  		= 'Password';
	$lang['lbl.employee.cconfirm_password'] = 'Confirm';
	$lang['lbl.employee.cemail']  			= 'Email';
	$lang['lbl.employee.cfirstname']  		= 'Firstname'; 
	$lang['lbl.employee.cmiddlename']  		= 'Middlename'; 
	$lang['lbl.employee.clastname']  		= 'Lassname'; 
	$lang['lbl.employee.cisadmin']  		= 'Permission'; 
	$lang['lbl.employee.cnote']  			= 'Note'; 
	
	

//Lang for sponline


	$lang['lbl.sponline.title.form']  		= 'Quản Lý Danh Mục Hỗ Trợ Trực Tuyến'; 
	$lang['lbl.sponline.FormEditTitle']		= 'Sửa Nick Hỗ Trợ';
	$lang['lbl.sponline.FormAddTitle']  	= 'Thêm Nick Hỗ Trợ'; 
	$lang['lbl.sponline.ccontact_nick']		= 'Nick hỗ trợ'; 
	$lang['lbl.sponline.cindex']			= 'Chỉ mục'; 
	$lang['lbl.sponline.cnote']				= 'Chú Thích'; 	
	$lang['lbl.sponline.nstatus']			= 'Trạng Thái'; 
	$lang['lbl.sponline.cname']				= 'Tên hỗ trợ'; 
	$lang['lbl.sponline.nid']				= 'Mã nick';
	$lang['lbl.sponline.date01']  			= 'Ngày tạo'; 
	$lang['lbl.sponline.niduser01']  		= 'Người tạo'; 


//Lang for email manager
	$lang['lbl.email_manager.title.form']  		= 'Quản Lý Danh Mục Địa Chỉ Email Liên Lạc'; 
	$lang['lbl.email_manager.FormEditTitle']	= 'Sửa Địa Chỉ Email';
	$lang['lbl.email_manager.FormAddTitle']  	= 'Thêm Địa Chỉ Email'; 
	$lang['lbl.email_manager.cemail_manager']	= 'Email'; 
	$lang['lbl.email_manager.cindex']			= 'Chỉ mục'; 
	$lang['lbl.email_manager.cnote']			= 'Chú Thích'; 	
	$lang['lbl.email_manager.nstatus']			= 'Trạng Thái'; 
	$lang['lbl.email_manager.cname']			= 'Tên Email'; 
	$lang['lbl.email_manager.nid']				= 'Mã email';
	$lang['lbl.email_manager.date01']  			= 'Ngày tạo'; 
	$lang['lbl.email_manager.niduser01']  		= 'Người tạo'; 

//Lang for config


	$lang['lbl.config.title.form']  		= 'Quản Lý Danh Mục Config'; 
	$lang['lbl.config.FormEditTitle']		= 'Sửa Thông Tin Config';
	$lang['lbl.config.FormAddTitle']  		= 'Thêm Thông Tin Config'; 
	$lang['lbl.config.ccode']				= 'Mã quản lý'; 
	$lang['lbl.config.cvalue']				= 'Giá trị'; 	
	$lang['lbl.config.cname']				= 'Tên thông tin';
	$lang['lbl.config.date01']  			= 'Ngày tạo'; 
	$lang['lbl.config.niduser01']  			= 'Người tạo'; 
	
//Lang for material

	$lang['lbl.material.title.form']  		= 'Section product manager'; 
	$lang['lbl.material.FormEditTitle']		= 'Edit section product';
	$lang['lbl.material.FormAddTitle']  	= 'Add section product'; 
	$lang['lbl.material.ccode']				= 'code'; 
	$lang['lbl.material.cmaterial']			= 'Section product'; 
	$lang['lbl.material.cnote']				= 'Note'; 	
	$lang['lbl.material.nstatus']			= 'Status';
	$lang['lbl.material.date01']  			= 'Date create'; 
	$lang['lbl.material.niduser01']  		= 'User create'; 
	$lang['lbl.material.index']  			= 'Index';
//Lang for cat

	$lang['lbl.cat.title.form']  		= 'Category product manager'; 
	$lang['lbl.cat.FormEditTitle']		= 'Edit category product';
	$lang['lbl.cat.FormAddTitle']  		= 'Add  category product'; 
	$lang['lbl.cat.ccode']				= 'Code'; 
	$lang['lbl.cat.cmaterial_product']	= 'Category product'; 
	$lang['lbl.cat.cnote']				= 'Note'; 	
	$lang['lbl.cat.nstatus']			= 'Status';
	$lang['lbl.cat.date01']  			= 'Date create'; 
	$lang['lbl.cat.niduser01']  		= 'User create'; 
	$lang['lbl.cat.index']  			= 'Index';
	$lang['lbl.cat.ccat_product']  		= 'Nhóm dự án';

//Lang for cat

	$lang['lbl.image_products.title.form']  		= 'Image product manager'; 
	$lang['lbl.image_products.FormEditTitle']		= 'Edit image product';
	$lang['lbl.image_products.FormAddTitle']  		= 'Add image product'; 
	$lang['lbl.image_products.ccode']				= 'Code'; 
	$lang['lbl.image_products.cimage']				= 'Image'; 
	$lang['lbl.image_products.cproduct']			= 'Product'; 
	$lang['lbl.image_products.cnote']				= 'Note'; 	
	$lang['lbl.image_products.nstatus']				= 'Status';
	$lang['lbl.image_products.date01']  			= 'Date create'; 
	$lang['lbl.image_products.niduser01']  			= 'User create'; 
	$lang['lbl.image_products.index']  				= 'index';
	$lang['lbl.image_products.btn_product']  	 	= 'Product manager'; 
	
//Lang for product
	$lang['lbl.product.title.form']  		= 'Product manager'; 
	$lang['lbl.product.FormEditTitle']		= 'Edit product';
	$lang['lbl.product.FormAddTitle']  		= 'Add product'; 
	$lang['lbl.product.ccode']				= 'Code'; 
	$lang['lbl.product.cproducts']			= 'Product';
	$lang['lbl.product.cnote']				= 'Note'; 
	$lang['lbl.product.cmodel']				= 'Model'; 
	$lang['lbl.product.cpower']				= 'Function'; 
	$lang['lbl.product.nspecial_product']	= 'Special product'; 	
	$lang['lbl.product.nstatus']			= 'Status';
	$lang['lbl.product.date01']  			= 'Date create'; 
	$lang['lbl.product.niduser01']  		= 'User create'; 
	$lang['lbl.product.cindex']  			= 'Index';  
	$lang['lbl.product.nid_metarial_product']= 'Section product';  
	$lang['lbl.product.nid_cat_product']  	= 'Category product'; 
	
	$lang['lbl.product.fprice']  			= 'Price'; 
	$lang['lbl.product.nquantity']  		= 'Weight'; 
	$lang['lbl.product.cdescription']  		= 'Description';
	$lang['lbl.product.cdetail']	  		= 'Product detail'; 
	
	$lang['lbl.product.cimage']  			= 'Image';
	$lang['lbl.product.add_image']  		= 'Add image';    
	
	$lang['lbl.product.choose_metarial_product'] = '-Select section product-';    
	$lang['lbl.product.choose_cat_product']  	 = '-Select category product-';   

	
//Lang for News 


	$lang['lbl.news.title.form']  			= 'Article manager';
	$lang['lbl.news.title.form_xml']		= 'Gen xml manager'; 
	$lang['lbl.news.title.tran.form'] 		= 'Quản Lý Danh Mục Bản Tin Được Dịch'; 
	$lang['lbl.news.FormEditTitle']			= 'Edit article';
	$lang['lbl.news.FormAddTitle']  		= 'Add article'; 
	$lang['lbl.news.image']					= 'Image Thumb';
	$lang['lbl.news.image_fb']				= 'Image FB';
	$lang['lbl.news.image_iphone']			= 'Image Iphone';
	$lang['lbl.news.nid']  					= 'ID'; 
	$lang['lbl.news.title']  				= 'Title'; 
	$lang['lbl.news.author']  				= 'Author'; 
	$lang['lbl.news.cat']  					= 'Category'; 
	$lang['lbl.news.index']  				= 'Index';
	$lang['lbl.news.section_news']			= 'Section'; 
	$lang['lbl.news.back']  				= 'Tin gốc'; 
//	$lang['lbl.news.status']  				= 'Trạng thái'; 
	$lang['lbl.news.status']  				= 'Published';
	$lang['lbl.news.active']  				= 'Active';
	$lang['lbl.news.user01']  				= 'User create'; 
	$lang['lbl.news.date01']  				= 'Date create'; 
	$lang['lbl.news.shortcontent']		  	= 'Short content';
	$lang['lbl.news.content']		  		= 'Full content';  
	$lang['lbl.news.thumbimg']			  	= 'Avata image (thumb)';
	$lang['lbl.news.img']  					= 'Detail image';
	$lang['lbl.news.alwcmt']				= 'Allow comment';
	$lang['lbl.news.lang']  				= 'Ngôn ngữ';
	$lang['lbl.news.first']					= ' gốc';
	$lang['lbl.news.trans']  				= 'Dịch';
	$lang['lbl.news.get_trans']  			= 'Xem bản dịch';
	$lang['lbl.news.full.trans']			= 'Đã có đủ bản dịch cho tất cả các ngôn ngữ!';
	$lang['lbl.news.err_delete']			= 'Đã đủ các bản tin dịch. Vui lòng xóa trước khi thêm mới!';
	$lang['lbl.news.err_delete_active']		= 'Article is active, can not delete !';
	
	
// Comment
	$lang['lbl.comment.title.form']  		= 'Quản Lý Comment'; 
	$lang['lbl.comment.title.tran.form'] 	= 'Quản Lý Comment'; 
	$lang['lbl.comment.FormEditTitle']		= 'Sửa Thông Tin Comment';
	$lang['lbl.comment.FormAddTitle']  		= 'Thêm Comment Mới'; 
	$lang['lbl.comment.comment']  			= 'Nội dung comment'; 
	$lang['lbl.comment.name']				= 'Họ tên';
	$lang['lbl.comment.index']  			= 'Chỉ mục'; 
	$lang['lbl.comment.status']  			= 'Trạng thái'; 
	$lang['lbl.comment.date01']  			= 'Ngày tạo'; 
	$lang['lbl.comment.title']  			= 'Email'; 
	
//Lang for Cat_news 


	$lang['lbl.cat_news.title.form']  		= 'CATEGORY MANAGER'; 
	$lang['lbl.cat_news.title.tran.form'] 	= 'Quản Lý Nhóm Tin Được Dịch'; 
	$lang['lbl.cat_news.FormEditTitle']		= 'Edit category';
	$lang['lbl.cat_news.FormAddTitle']  	= 'Add category'; 
	$lang['lbl.cat_news.cat_news']  		= 'Category'; 
	$lang['lbl.cat_news.nid']				= 'ID';
	$lang['lbl.cat_news.section_news']		= 'Section';
	$lang['lbl.cat_news.index']  			= 'Index'; 
	$lang['lbl.cat_news.status']  			= 'Status'; 
	$lang['lbl.cat_news.note']  			= 'Description'; 
	$lang['lbl.cat_news.ccode']  			= 'Code'; 	
	$lang['lbl.cat_news.date01']  			= 'Date create'; 
	$lang['lbl.cat_news.niduser01']  		= 'User create'; 
	$lang['lbl.cat_news.lang']  			= 'Language';	
	$lang['lbl.cat_news.back']  			= 'Nhóm tin gốc'; 	
	$lang['lbl.cat_news.first']				= ' gốc';
	$lang['lbl.cat_news.no_edit_lang']		= ' Ngôn ngữ nhóm tin không được sửa!';	
	$lang['lbl.cat_news.trans'] 			= 'Dịch';
	$lang['lbl.cat_news.get_trans']  		= 'Xem bản dịch';
	$lang['lbl.cat_news.full.trans']		= 'Đã có đủ các nhóm tin cho tất cả các ngôn ngữ!';
	$lang['lbl.cat_news.err_delete']		= 'Nhóm tin này có chứa mẫu tin khác không thể xóa !';
	$lang['lbl.cat_news.err_nid_cat_news']	= 'Nhóm tin gốc này chưa có bản dịch. Xin vui lòng thêm nhóm tin dịch để tiếp tục!';
	
//Lang for Section_news 
	$lang['lbl.section_news.title.form']  		= 'SECTION MANAGER'; 
	$lang['lbl.section_news.title.tran.form'] 	= 'Quản Lý Loại Tin Được Dịch'; 
	$lang['lbl.section_news.FormEditTitle']		= 'EDIT SECTION';
	$lang['lbl.section_news.FormAddTitle']  	= 'ADD SECTION'; 
	$lang['lbl.section_news.section_news']  	= 'Section'; 
	$lang['lbl.section_news.nid']				= 'ID';
	$lang['lbl.section_news.index']  			= 'Index'; 
	$lang['lbl.section_news.status']  			= 'Status'; 
	$lang['lbl.section_news.note']  			= 'Description'; 
	$lang['lbl.section_news.ccode']  			= 'Code'; 	
	$lang['lbl.section_news.date01']  			= 'Date create'; 
	$lang['lbl.section_news.niduser01']  		= 'User create'; 
	$lang['lbl.section_news.lang']  			= 'languge';	
	$lang['lbl.section_news.back']  			= 'Nhóm tin gốc'; 	
	$lang['lbl.section_news.first']				= ' gốc';
	$lang['lbl.section_news.no_edit_lang']		= ' Ngôn ngữ nhóm tin không được sửa!';	
	$lang['lbl.section_news.trans'] 			= 'Dịch';
	$lang['lbl.section_news.get_trans']  		= 'Xem bản dịch';
	$lang['lbl.section_news.full.trans']		= 'Đã có đủ các nhóm tin cho tất cả các ngôn ngữ!';
	$lang['lbl.section_news.err_delete']		= 'Nhóm tin này có chứa mẫu tin khác không thể xóa !';
	$lang['lbl.section_news.err_nid_cat_news']	= 'Nhóm tin gốc này chưa có bản dịch. Xin vui lòng thêm nhóm tin dịch để tiếp tục!';
	

	
	

//Lang for Module 
	$lang['lbl.module.title.form']  		= 'MODULES MANAGER'; 
	$lang['lbl.module.title.tran.form'] 	= 'Quản Lý Module Được Dịch'; 
	$lang['lbl.module.FormEditTitle']		= 'Edit Module ';
	$lang['lbl.module.FormAddTitle']  		= 'Add Module'; 
	$lang['lbl.module.module']  			= 'Module'; 
	$lang['lbl.module.nid']					= 'ID';
	$lang['lbl.module.index']  				= 'Index'; 
	$lang['lbl.module.status']  			= 'Status'; 
	$lang['lbl.module.note']  				= 'Note'; 
	$lang['lbl.module.ccode']  				= 'Code'; 	
	$lang['lbl.module.date01']  			= 'Date create'; 
	$lang['lbl.module.niduser01']  			= 'user create'; 
	$lang['lbl.module.lang']  				= 'Ngôn ngữ';	
	$lang['lbl.module.back']  				= 'Module gốc'; 	
	$lang['lbl.module.first']				= ' gốc';
	$lang['lbl.module.no_edit_lang']		= ' Ngôn ngữ nhóm tin không được sửa!';	
	$lang['lbl.module.trans'] 				= 'Dịch';
	$lang['lbl.module.get_trans']  			= 'Xem bản dịch';
	$lang['lbl.module.full.trans']			= 'Đã có đủ các nhóm tin cho tất cả các ngôn ngữ!';
	$lang['lbl.module.err_delete']			= 'Nhóm tin này có chứa mẫu tin khác không thể xóa !';
	$lang['lbl.module.err_nid_cat_news']	= 'Nhóm tin gốc này chưa có bản dịch. Xin vui lòng thêm nhóm tin dịch để tiếp tục!'; 


//Lang for Section_news 
	$lang['lbl.cat_faq.title.form']  		= 'Quản Lý Loại Hỏi Đáp'; 
	$lang['lbl.cat_faq.title.tran.form'] 	= 'Quản Lý Loại Hỏi Đáp Được Dịch'; 
	$lang['lbl.cat_faq.FormEditTitle']		= 'Sửa Thông Tin Loại Hỏi Đáp';
	$lang['lbl.cat_faq.FormAddTitle']  		= 'Thêm Loại Hỏi Đáp Mới'; 
	$lang['lbl.cat_faq.cat_faq']  			= 'Tên loại hỏi đáp'; 
	$lang['lbl.cat_faq.nid']				= 'Mã loại hỏi đáp';
	$lang['lbl.cat_faq.index']  			= 'Chỉ mục'; 
	$lang['lbl.cat_faq.status']  			= 'Trạng thái'; 
	$lang['lbl.cat_faq.note']  				= 'Ghi chú'; 
	$lang['lbl.cat_faq.ccode']  			= 'Mã quản lý'; 	
	$lang['lbl.cat_faq.date01']  			= 'Ngày tạo'; 
	$lang['lbl.cat_faq.niduser01']  		= 'Người tạo'; 
	$lang['lbl.cat_faq.lang']  				= 'Ngôn ngữ';	
	$lang['lbl.cat_faq.back']  				= 'Nhóm tin gốc'; 	
	$lang['lbl.cat_faq.first']				= ' gốc';
	$lang['lbl.cat_faq.no_edit_lang']		= ' Ngôn ngữ nhóm tin không được sửa!';	
	$lang['lbl.cat_faq.trans'] 				= 'Dịch';
	$lang['lbl.cat_faq.get_trans']  		= 'Xem bản dịch';
	$lang['lbl.cat_faq.full.trans']			= 'Đã có đủ các nhóm tin cho tất cả các ngôn ngữ!';
	$lang['lbl.cat_faq.err_delete']			= 'Loại hỏi đáp này có chứa mẫu tin khác không thể xóa !';
	$lang['lbl.cat_faq.err_nid_cat_news']	= 'Loại hỏi đáp này chưa có bản dịch. Xin vui lòng thêm nhóm tin dịch để tiếp tục!';

//Lang for support_online
	$lang['lbl.support_online.title.form']  	= 'SUPPORT ONLINE MANAGER'; 
	$lang['lbl.support_online.FormEditTitle']	= 'Edit support online';
	$lang['lbl.support_online.FormAddTitle']  	= 'Add support online'; 
	$lang['lbl.support_online.ccode']			= 'Nick'; 
	$lang['lbl.support_online.csupport_online']	= 'support online'; 
	$lang['lbl.support_online.cnote']			= 'Note'; 	
	$lang['lbl.support_online.nstatus']			= 'Status';
	$lang['lbl.support_online.ntype']			= 'Type';
	$lang['lbl.support_online.date01']  		= 'Date create'; 
	$lang['lbl.support_online.niduser01']  		= 'User create'; 
	$lang['lbl.support_online.index']  			= 'Index';

//Lang for config
	$lang['lbl.config.title.form']  		= 'CONFIG MANAGER'; 
	$lang['lbl.config.FormEditTitle']		= 'Edit config';
	$lang['lbl.config.FormAddTitle']  		= 'Add config'; 
	$lang['lbl.config.cvalue']				= 'Value'; 
	$lang['lbl.config.cname']				= 'Name'; 
	$lang['lbl.config.cnote']				= 'Note'; 	
	$lang['lbl.config.date01']  			= 'Date create'; 
	$lang['lbl.config.niduser01']  			= 'User create'; 

//Lang for sponline
	$lang['lbl.menu_frontend.title.form']  			= 'Menu Frontend Manager'; 
	$lang['lbl.menu_frontend.FormEditTitle']		= 'Edit menu';
	$lang['lbl.menu_frontend.FormAddTitle']  		= 'Add menu'; 
	$lang['lbl.menu_frontend.ccode']				= 'Code'; 
	$lang['lbl.menu_frontend.cmenu']				= 'Menu'; 
	$lang['lbl.menu_frontend.nid_function_frontend']= 'Menu type';
	$lang['lbl.menu_frontend.iditem']				= 'Menu code';  
	$lang['lbl.menu_frontend.nindex']				= 'Index'; 
	$lang['lbl.menu_frontend.cnote']				= 'Note'; 	
	$lang['lbl.menu_frontend.cwidth']				= 'Width'; 	
	$lang['lbl.menu_frontend.nstatus']				= 'Published'; 
	$lang['lbl.menu_frontend.date01']  				= 'Date create'; 
	$lang['lbl.menu_frontend.niduser01']  			= 'User create'; 
	$lang['lbl.menu_frontend.nid_parent']  			= 'Menu parent'; 
	

/*----------------------------------------------------------------------------------------------*/
// THONG TIN NGON NGU DUNG CHO MAN HINH LOAD MENU TYPE (quan ly menu)
// an_hm87
	$lang['lbl.load_menu_type.product_detail'] 		= 'Bạn chọn loại menu là chi tiết sản phẩm, Xin vui lòng chọn sản phẩm mà bạn muốn hiển thị cho menu';	
	$lang['lbl.load_menu_type.ajax_load_default'] 	= 'You choose menu type default, no config , You can click update to save and view menu';
	$lang['lbl.load_menu_type.ajax_load_sec_news'] 	= 'Bạn chọn loại menu là loại tin, xin vui lòng chọn loại tin mà bạn muốn hiển thị cho menu';
	$lang['lbl.load_menu_type.ajax_load_cat_news'] 	= '<p>Bạn chọn loại menu là nhóm tin, xin vui lòng chọn nhóm tin mà bạn muốn hiển thị cho menu</p><p>Cấu trúc: Loại tin / Nhóm tin</p>';
	$lang['lbl.load_menu_type.ajax_load_sec_product'] 	= 'Bạn chọn loại menu là loại sản phẩm, xin vui lòng chọn loại sản phẩm mà bạn muốn hiển thị cho menu';
	$lang['lbl.load_menu_type.ajax_load_cat_product'] 	= '<p>Bạn chọn loại menu là nhóm sản phẩm, xin vui lòng chọn nhóm sản phẩm mà bạn muốn hiển thị cho menu</p><p>Cấu trúc: Loại san phẩm / Nhóm sản phẩm</p>';
	$lang['lbl.load_menu_type.ajax_load_article'] 		= 'You choose the menu is an article, please select the article you want to display the menu.';
	
	
	$lang['lbl.load_menu_type.select_article']		= 'Choose article';
	$lang['lbl.load_menu_type.carticle']			= 'Article';	
	$lang['lbl.load_menu_type.sec_article']			= 'Section article';	
	$lang['lbl.load_menu_type.cat_article']			= 'Category article';
	
	$lang['lbl.load_menu_type.select_product']		= 'Chọn sản phẩm';
	$lang['lbl.load_menu_type.cproduct']  			= 'Tên sản phẩm';
	$lang['lbl.load_menu_type.sec_product']			= 'Loại sản phẩm';
	$lang['lbl.load_menu_type.cat_product']  		= 'Nhóm sản phẩm';	

//Lang for banner images
	$lang['lbl.banner_images.title.form']  		= 'Banner Images Manager'; 
	$lang['lbl.banner_images.FormEditTitle']	= 'Edit Banner Images';
	$lang['lbl.banner_images.FormAddTitle']  	= 'Add Banner Images'; 
	$lang['lbl.banner_images.nid']				= 'ID';
	$lang['lbl.banner_images.index']  			= 'Index'; 
	$lang['lbl.banner_images.status']  			= 'Status'; 
	$lang['lbl.banner_images.note']  			= 'Note'; 
	$lang['lbl.banner_images.ccode']  			= 'Code'; 
	$lang['lbl.banner_images.banner_images']  	= 'Image name';	
	$lang['lbl.banner_images.date01']  			= 'Date create'; 
	$lang['lbl.banner_images.niduser01']  		= 'User create'; 

//Lang for customer
	$lang['lbl.customer.title.form']  		= 'Customer Management'; 
	$lang['lbl.customer.FormEditTitle']		= 'Edit Customer Info';
	$lang['lbl.customer.FormAddTitle']  	= 'Add New Customer'; 
	$lang['lbl.customer.customerid']		= 'Customer ID'; 
	$lang['lbl.customer.cpassword']			= 'Password'; 
	$lang['lbl.customer.cemail']			= 'Email'; 	
	$lang['lbl.customer.chandphone']		= 'Phone'; 	
	$lang['lbl.customer.cfirstname']		= 'First name'; 	
	$lang['lbl.customer.cmiddlename']		= 'Middle name'; 	
	$lang['lbl.customer.clastname']			= 'Last name'; 	
	$lang['lbl.customer.caddress']			= 'Address'; 	

	$lang['lbl.customer.nstatus']			= 'Status';
	$lang['lbl.customer.date01']  			= 'Date create'; 
	$lang['lbl.customer.niduser01']  		= 'User create'; 
	$lang['lbl.customer.cindex']  			= 'Index';  
	
//Lang for customer
	$lang['lbl.order.title.form']  		= 'Order Managerment'; 
	$lang['lbl.order.FormEditTitle']	= 'Confirm Order';
	$lang['lbl.order.FormAddTitle']  	= 'Add Order'; 
	$lang['lbl.order.ccode']			= 'Code'; 
	$lang['lbl.order.cfullname']		= 'Customer name'; 
	$lang['lbl.order.cemail']			= 'Email'; 	
	$lang['lbl.order.nphone']			= 'Phone'; 	
	$lang['lbl.order.cnote']			= 'Note'; 	
	$lang['lbl.order.caddress']			= 'Address'; 	

	$lang['lbl.order.nid_order_status']	= 'Status';
	$lang['lbl.order.date01']  			= 'Date create'; 
	$lang['lbl.order.date02']  			= 'Date modify';
	
	$lang['lbl.order.order_infomation']		= 'Order Information'; 
	$lang['lbl.order.product_infomation']	= 'Product Information'; 
	
	$lang['lbl.order.cproduct']  			= 'Product';
	$lang['lbl.order.nquantity']  			= 'Quantity';
	$lang['lbl.order.fprice']  				= 'Price';
	$lang['lbl.order.ftotal']  				= 'Price total';
	$lang['lbl.order.fsum']  				= 'Sum Total';
	$lang['lbl.order.vnd']  				= 'VNĐ';
	
	

?>