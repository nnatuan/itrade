<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

function Vuser_view()
{
	$str=' (SELECT ';
	$str.=' a.nid 			as nid 			,';
	$str.=' a.ccode 		as ccode 		,';
	$str.=' a.cnote 		as cnote 		,';
	$str.=' a.niduser01 	as niduser01 	,';
	$str.=' a.niduser02 	as niduser02 	,';
	$str.=' a.ddate01 		as ddate01 		,';
	$str.=' a.ddate02 		as ddate02 		,';
	$str.=' a.cuserid 		as cuserid 		,';
	$str.=' a.cpassword 	as cpassword 	,';
	$str.=' a.cemail 		as cemail 		,';
	$str.=' a.cfirstname 	as cfirstname 	,';
	$str.=' a.cmiddlename 	as cmiddlename 	,';
	$str.=' a.clastname 	as clastname 	,';	
	$str.=' a.cstatus 	as cstatus 	,';	
	$str.=' concat(a.cfirstname, " " ,  a.cmiddlename, " " , a.clastname)	as cfullname 	,';	
	$str.=' b.cuser_type 	as cisadmin_name,';
	$str.=' a.cisadmin 	as cisadmin 		 ';
	$str.=' FROM ' . Fget_ap_table('tuser') . ' as a , ' . Fget_ap_table('tuser_type') . ' as b';
	$str.=' WHERE a.cdel="0" AND a.cisadmin=b.nid'; 
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}

//
// Danh muc kenh bao cao
//
function Vdepartment_group_view()
{
	$str =' (SELECT ';
	$str.=' a.nid 			as nid 			,';
	$str.=' a.cnote 		as cnote 		,';
	$str.=' a.niduser01 	as niduser01 	,';
	$str.=' a.niduser02 	as niduser02 	,';
	$str.=' a.ddate01 		as ddate01 		,';
	$str.=' a.ddate02 		as ddate02 		,';	
	$str.=' a.ccode			as ccode		,';
	$str.=' a.cgroup		as cgroup		';
	$str.=' FROM ' . Fget_ap_table('tdepartment_group') 	. ' as a ';
	$str.=' WHERE a.cdel="0" '; 
	$str.=' ) ';
	$str.=' as view ';
	
	return $str;
}

//
// huan_lv77
//
function Vdepartment_view()
{
	$str=' (SELECT ';
	$str.=' a.nid 			as nid ,';
	$str.=' a.ccode 		as ccode ,';
	$str.=' a.cdepartment 	as cdepartment ,';
	$str.=' a.nid_index 	as nid_index ,';
	$str.=' a.cindex 		as cindex ,';
	$str.=' a.nid_user 		as nid_user ,';
	$str.=' concat(b.cfirstname, " " ,  b.cmiddlename, " " , b.clastname)	as cfullname 	,';	
	$str.=' a.nid_department_group 	as nid_department_group,';
	$str.=' c.cgroup		as cgroup,';
	
	$str.=' a.cdel 			as cdel ,';
	$str.=' a.cnote 		as cnote ,';
	$str.=' a.cstatus 		as cstatus ,';
	$str.=' a.niduser01 	as niduser01 ,';
	$str.=' a.niduser02 	as niduser02 ,';
	$str.=' a.ddate01 		as ddate01 ,';
	$str.=' a.ddate02 		as ddate02 ';
	
	$str.=' FROM ' . Fget_ap_table('tdepartment')	. ' as a ,';
	$str.='      ' . Fget_ap_table('tuser')    	. ' as b ,';
	$str.='      ' . Fget_ap_table('tdepartment_group') . ' as c ';
	$str.=' WHERE a.cdel="0" '; 
	$str.=' AND   a.nid_user=b.nid'; 
	$str.=' AND   a.nid_department_group=c.nid'; 
	$str.=' ) as view'; 
	
	return $str;
}	
//
// Danh muc kenh bao cao
//

function Vmenu_view() 	
{		
	$str=' ( ';
	$str.=' SELECT ';
	$str.=' a.nid 			as nid 	,';
	$str.=' a.cmenu 		as cmenu 	,';
	$str.=' a.cicon_name 	as cicon_name 	,';	
	$str.=' a.cbasic 		as isbasic 	,';	
	$str.=' a.cindex 		as cindex 	,';	
	$str.=' a.cnode 		as cnode 	,';	
	$str.=' a.cbasic 		as cbasic 	,';	
	$str.=' a.cstatus 		as ccstatus 	';
		
	$str.=' FROM ' ;
	$str.='      ' . Fget_ap_table('tmenu')	. ' as a ';	
	$str.=' WHERE  	a.nid is not null AND a.cdel=0 AND a.cstatus=1';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
	
function Vuser_menu_view()
{
	return ' (SELECT * FROM tuser WHERE cdel="0") as vuser ';
}


//
// phu_ca86
// DM Tin tuc
function Vnew_view()
{
	$str ='(SELECT';
	$str.=' a.nid				as nid ,';
	$str.=' a.nid_cat_news		as nid_cat ,';
	$str.=' b.ccat_news			as ccat_news ,';
	$str.=' a.ctitle			as ctitle ,';
	
	$str.=' a.cindex			as cindex ,';
	$str.=' a.ctag				as ctag ,';
	$str.=' a.nimg				as nimg ,';
	$str.=' a.alwcmt			as alwcmt ,';
	$str.=' a.nstatus 			as nstatus ,';
	$str.=' a.nactive 			as nactive ,';
	$str.=' a.chome 			as chome ,';
	$str.=' a.cmphq 			as cmphq ,';
	$str.=' a.cmp365			as cmp365 ,';
	$str.=' a.niduser01 		as niduser01 ,';
	$str.=' a.nid_section_news	as nid_section_news ,';
	$str.=' c.csection_news		as csection_news ,';	
	$str.=' a.ddate01 			as ddate01, ';
	$str.=' a.ddate01 			as ddate02 ';
	$str.=' FROM ' . Fget_ap_table('tsection_news') . ' as c	 ,';
	$str.= 		     Fget_ap_table('tnews') . ' as a';
	$str.= ' LEFT JOIN '. Fget_ap_table('tcat_news') . ' as b  ON (a.nid_cat_news = b.nid) ';
	//$str.= 				Fget_ap_table('ttranslate') . ' as d ,';
	//$str.= 				Fget_ap_table('tlanguage') . ' as e ';
	
	$str.=' WHERE 	a.nid is not null ';
	$str.=' AND 	a.nid_section_news 	= c.nid ';
	//$str.=' AND 	d.nid_language	  	= e.nid';
	//$str.=' AND 	d.nid_translate		= a.nid';
	//$str.=' AND 	d.ctbl_name 		= "tnews" ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}


function Vbanner_view()
{	
	$str=' (SELECT ';
	$str.=' a.nid					as nid ,';
	$str.=' a.cimage				as cimage,';
	$str.=' a.ctext					as ctext ,';
	$str.=' a.clink					as clink ,';
	$str.=' a.cstatus				as cstatus ,';
	$str.=' concat(b.cfirstname, " " , b.cmiddlename, " " , b.clastname)	as cfullname 	,';	
	$str.=' a.niduser01				as nid_user01 ,';
	$str.=' a.ddate01				as ddate01';
	$str.=' FROM ' . Fget_ap_table('tbanner') .' as a ,';
	$str.=  Fget_ap_table('tuser') .' as b ';
	$str.=' WHERE 	a.niduser01 = b.nid ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}


function Vsection_new_view()
{
	$str=' (SELECT ';

	$str.=' a.nid					as nid ,';
	$str.=' a.csection_news			as csection_news,';
	$str.=' a.cnote					as cnote ,';
	$str.=' a.ccode					as ccode ,';
	$str.=' a.ctag					as ctag ,';	
	$str.=' a.nstatus				as nstatus ,';
	$str.=' a.cindex				as cindex ,';
	$str.=' a.niduser01				as nid_user01 ,';
	
	//$str.=' b.nid_org				as nid_org ,';
	//$str.=' b.nid_language			as nid_language,';
	//$str.=' b.nid_translate			as nid_translate,';
	//$str.=' b.ctbl_name				as ctbl_name,';
	
	//$str.=' c.clanguage				as clanguage,';	
	$str.=' a.ddate01				as ddate01';
	$str.=' FROM ' . Fget_ap_table2('tsection_news') . ' as a ' ;
	//$str.='      ' . Fget_ap_table2('ttranslate'). ' as b ,';
	//$str.='      ' . Fget_ap_table2('tlanguage') . ' as c ';
	//$str.=' WHERE a.nid 		= b.nid_translate '; 
	//$str.=' AND   c.nid 		= b.nid_language'; 
//	$str.=' AND   b.ctbl_name 		= "tcat_news"';
	$str.=') as view ';
	return $str;
}

function Vcat_new_view()
{
	$str=' (SELECT ';

	$str.=' a.nid					as nid ,';
	$str.=' a.ccat_news				as ccat_news,';
	$str.=' a.cnote					as cnote ,';
	$str.=' a.nspecial			as nspecial ,';
	$str.=' a.ccode					as ccode ,';
	$str.=' a.ctag					as ctag ,';	
	$str.=' a.nstatus				as nstatus ,';
	$str.=' a.cindex				as cindex ,';
	$str.=' a.niduser01				as nid_user01 ,';
	
	$str.=' a.nid_section_news		as nid_section_news ,';
	$str.=' d.csection_news			as csection_news ,';
	
	//$str.=' b.nid_org				as nid_org ,';
	//$str.=' b.nid_language			as nid_language,';
	//$str.=' b.nid_translate			as nid_translate,';
	//$str.=' b.ctbl_name				as ctbl_name,';
	
	//$str.=' c.clanguage				as clanguage,';
	$str.=' a.ddate01				as ddate01';
	$str.=' FROM ' . Fget_ap_table2('tcat_news') . ' as a ,' ;
	//$str.='      ' . Fget_ap_table2('ttranslate'). ' as b ,';
	//$str.='      ' . Fget_ap_table2('tlanguage') . ' as c, ';
	$str.='      ' . Fget_ap_table2('tsection_news') . ' as d ';
	$str.=' WHERE a.nid 		is not null '; 
	//$str.=' AND   c.nid 		= b.nid_language'; 
	$str.=' AND   d.nid 		= a.nid_section_news'; 
//	$str.=' AND   b.ctbl_name 		= "tcat_news"';
	$str.=') as view ';
	return $str;
}

function Vsponline_view()
{
	$str=' (SELECT ';
	$str.=' a.nid					as nid ,';
	$str.=' a.ccontact_nick			as ccontact_nick,';
	$str.=' a.cname					as cname,';	
	$str.=' a.cindex				as cindex,';
	$str.=' a.nstatus				as nstatus,';
	$str.=' a.cnote					as cnote,';		
	$str.=' a.niduser01				as niduser01 ,';
	$str.=' a.niduser02				as niduser02 ,';
	$str.=' concat(b.cfirstname, " " , b.cmiddlename, " " , b.clastname)	as cfullname 	,';	
	$str.=' a.ddate01				as ddate01 ,';
	$str.=' a.ddate02				as ddate02 ';
	$str.=' FROM ' . Fget_ap_table('tsponline') . ' as a , ' . Fget_ap_table('tuser') . ' as b';
	$str.=' WHERE a.niduser01=b.nid'; 
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}

function Vemail_manager_view()
{
	$str=' (SELECT ';
	$str.=' a.nid					as nid ,';
	$str.=' a.cemail_manager		as cemail_manager,';
	$str.=' a.cname					as cname,';	
	$str.=' a.cindex				as cindex,';
	$str.=' a.nstatus				as nstatus,';
	$str.=' a.cnote					as cnote,';		
	$str.=' a.niduser01				as niduser01 ,';
	$str.=' a.niduser02				as niduser02 ,';
	$str.=' concat(b.cfirstname, " " , b.cmiddlename, " " , b.clastname)	as cfullname 	,';	
	$str.=' a.ddate01				as ddate01 ,';
	$str.=' a.ddate02				as ddate02 ';
	$str.=' FROM ' . Fget_ap_table('temail_manager') . ' as a , ' . Fget_ap_table('tuser') . ' as b';
	$str.=' WHERE a.niduser01=b.nid'; 
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}

function Vhotline_view()
{
	$str=' (SELECT ';
	$str.=' a.nid						as nid,';	
	$str.=' a.cphone					as cphone,';	
	$str.=' a.cindex					as cindex,';		
	$str.=' a.niduser01				as niduser01 ,';
	$str.=' a.niduser02				as niduser02 ,';
	$str.=' concat(b.cfirstname, " " , b.cmiddlename, " " , b.clastname)	as cfullname 	,';	
	$str.=' a.ddate01				as ddate01 ,';
	$str.=' a.ddate02				as ddate02 ';
	$str.=' FROM ' . Fget_ap_table('tphone') . ' as a , ' . Fget_ap_table('tuser') . ' as b';
	$str.=' WHERE a.niduser01=b.nid'; 
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}

function Vconfig_view()
{
	$str=' (SELECT ';
	$str.=' a.nid					as nid ,';
	$str.=' a.ccode					as ccode,';
	$str.=' a.cvalue				as cvalue,';
	$str.=' a.cname				as cname,';		
	$str.=' a.nstatus				as nstatus,';
	$str.=' a.niduser01				as niduser01 ,';
	$str.=' a.niduser02				as niduser02 ,';
	$str.=' concat(b.cfirstname, " " , b.cmiddlename, " " , b.clastname)	as cfullname 	,';	
	$str.=' a.ddate01				as ddate01 ,';
	$str.=' a.ddate02				as ddate02 ';
	$str.=' FROM ' . Fget_ap_table('tconfig') . ' as a , ' . Fget_ap_table('tuser') . ' as b';
	$str.=' WHERE a.niduser01=b.nid'; 
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}

function Vmodule_view()
{
	$str=' (SELECT ';

	$str.=' a.nid					as nid ,';
	$str.=' a.cmodule				as cmodule,';
	$str.=' a.cnote					as cnote ,';
	$str.=' a.ccode					as ccode ,';
	$str.=' a.ctag					as ctag ,';	
	$str.=' a.clink				as clink ,';
	$str.=' a.nstatus				as nstatus ,';
	$str.=' a.cindex				as cindex ,';
	$str.=' a.niduser01				as nid_user01 ,';
		
	$str.=' a.ddate01				as ddate01,';
	$str.=' a.ddate01				as ddate02';
	$str.=' FROM ' . Fget_ap_table2('tmodule') . ' as a ' ;
	$str.=') as view ';
	return $str;
}

function Vtopmenu_view()
{
	$str=' (SELECT ';
	$str.=' a.nid					as nid ,';
	$str.=' a.ctopmenu				as ctopmenu,';
	$str.=' a.cnote					as cnote ,';
	$str.=' a.clink					as clink ,';
	$str.=' a.ctag					as ctag ,';	
	$str.=' a.nstatus				as nstatus ,';
	$str.=' a.cindex				as cindex ,';
	$str.=' a.niduser01				as nid_user01 ,';
		
	$str.=' a.ddate01				as ddate01';
	$str.=' FROM ' . Fget_ap_table2('ttopmenu') . ' as a ' ;
	$str.=') as view ';
	return $str;
}


function Vbanner_images_view()
{
	$str=' (SELECT ';

	$str.=' a.nid					as nid ,';
	$str.=' a.cbanner_images		as cbanner_images,';
	$str.=' a.cimage				as cimage,';
	$str.=' a.cnote					as cnote ,';
	$str.=' a.ccode					as ccode ,';
	$str.=' a.ctag					as ctag ,';	
	$str.=' a.nstatus				as nstatus ,';
	$str.=' a.cindex				as cindex ,';
	$str.=' a.niduser01				as nid_user01 ,';
	
	//$str.=' b.nid_org				as nid_org ,';
	//$str.=' b.nid_language			as nid_language,';
	//$str.=' b.nid_translate			as nid_translate,';
	//$str.=' b.ctbl_name				as ctbl_name,';
	
	//$str.=' c.clanguage				as clanguage,';	
	$str.=' a.ddate01				as ddate01,';
	$str.=' a.ddate02				as ddate02';
	$str.=' FROM ' . Fget_ap_table2('tbanner_images') . ' as a ' ;
	//$str.='      ' . Fget_ap_table2('ttranslate'). ' as b ,';
	//$str.='      ' . Fget_ap_table2('tlanguage') . ' as c ';
	//$str.=' WHERE a.nid 		= b.nid_translate '; 
	//$str.=' AND   c.nid 		= b.nid_language'; 
//	$str.=' AND   b.ctbl_name 		= "tcat_news"';
	$str.=') as view ';
	return $str;
}



function Vsupport_online()
{
	$str=' (SELECT ';
	$str.=' a.nid					as nid ,';
	$str.=' a.ccode					as ccode,';
	$str.=' a.csupport_online		as csupport_online,';
	$str.=' a.cnote					as cnote,';
	$str.=' a.nstatus				as nstatus,';
	$str.=' a.ntype					as ntype,';	
	$str.=' a.cindex				as cindex,';
	$str.=' a.niduser01				as niduser01 ,';
	$str.=' a.niduser02				as niduser02 ,';
	$str.=' a.ddate01				as ddate01 ,';
	$str.=' a.ddate02				as ddate02 ';
	
	$str.=' FROM ' . Fget_ap_table('tsupport_online') . ' as a  ';
	$str.=' WHERE a.nid is not null';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}

function Vconfig()
{
	$str=' (SELECT ';
	$str.=' a.nid					as nid ,';
	$str.=' a.cname					as cname,';
	$str.=' a.cvalue				as cvalue,';
	$str.=' a.cnote					as cnote,';
	$str.=' a.nstatus					as nstatus,';
	$str.=' a.niduser01				as niduser01 ,';
	$str.=' a.niduser02				as niduser02 ,';
	$str.=' a.ddate01				as ddate01 ,';
	$str.=' a.ddate02				as ddate02 ';
	
	$str.=' FROM ' . Fget_ap_table('tconfig') . ' as a  ';
	$str.=' WHERE a.nid is not null';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}

function Vmenu_frontend_view()
{
	$str=' (SELECT ';
	$str.=' a.nid					as nid ,';
	$str.=' a.ccode					as ccode,';
	$str.=' a.cmenu					as cmenu,';	
	$str.=' a.nid_function_frontend	as nid_function_frontend,';
	$str.=' a.id_item				as id_item,';
	$str.=' a.cnote					as cnote,';	
	$str.=' a.ccat_index			as ccat_index,';	
	$str.=' a.nindex				as nindex,';
	$str.=' a.nstatus				as nstatus,';
	$str.=' a.cdel					as cdel,';
	$str.=' a.nbasic				as nbasic,';		
	$str.=' a.niduser01				as niduser01 ,';
	$str.=' a.niduser02				as niduser02 ,';	
	$str.=' a.ddate01				as ddate01 ,';
	$str.=' a.ddate02				as ddate02 ';
	$str.=' FROM ' . Fget_ap_table('tmenu_frontend') . ' as a  '; 
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}

function Vmateria_product()
{
	$str=' (SELECT ';
	$str.=' a.nid					as nid ,';
	$str.=' a.ccode					as ccode,';
	$str.=' a.cmaterial_products	as cmaterial_products,';
	$str.=' a.cimage				as cimage,';
	$str.=' a.ctag					as ctag,';
	$str.=' a.cnote					as cnote,';
	$str.=' a.nstatus				as nstatus,';
	$str.=' a.nspecial				as nspecial,';	
	$str.=' a.cindex				as cindex,';
	$str.=' a.niduser01				as niduser01 ,';
	$str.=' a.niduser02				as niduser02 ,';
	$str.=' a.ddate01				as ddate01 ,';
	$str.=' a.ddate02				as ddate02 ';
	
	$str.=' FROM ' . Fget_ap_table('tmaterial_products') . ' as a  ';
	$str.=' WHERE a.nid is not null';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}

function Vcat_product()
{
	$str=' (SELECT ';
	$str.=' a.nid					as nid ,';
	$str.=' a.ccode					as ccode,';
	$str.=' a.ccat_products			as ccat_products,';
	$str.=' c.nid					as nid_material_products,';
	$str.=' c.cmaterial_products	as cmaterial_products,';
	$str.=' a.cimage				as cimage,';
	$str.=' a.ctag					as ctag,';
	$str.=' a.cnote					as cnote,';
	$str.=' a.nstatus				as nstatus,';	
	$str.=' a.cindex				as cindex,';	
	$str.=' a.niduser01				as niduser01 ,';
	$str.=' a.niduser02				as niduser02 ,';
	$str.=' a.ddate01				as ddate01 ,';
	$str.=' a.ddate02				as ddate02 ';
	
	$str.=' FROM ' . Fget_ap_table('tcat_products') . ' as a , ';
	$str.=' '. Fget_ap_table('tmaterial_products') . ' as c ';
	$str.=' WHERE a.nid is not null ';
	$str.=' AND a.nid_material_products = c.nid';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}

function Vproduct()
{
	$str=' (SELECT ';
	$str.=' a.nid					as nid ,';
	$str.=' a.ccode					as ccode,';
	$str.=' a.cproducts				as cproducts,';
	
	$str.=' a.nid_material_products	as nid_material_products,';
	$str.=' c.cmaterial_products	as cmaterial_products,';
	$str.=' a.nid_cat_products		as nid_cat_products,';
	$str.=' a.nid_brand_products	as nid_brand_products,';	
	$str.=' b.ccat_products			as ccat_products,';
	
	$str.=' a.cimage				as cimage,';
	$str.=' a.cimage_resize			as cimage_resize,';
	$str.=' a.fprice				as fprice,';
	$str.=' a.fprice_sale			as fprice_sale,';
	//$str.=' a.nquantity				as nquantity,';
	$str.=' a.cdescription			as cdescription,';
	$str.=' a.cdetail				as cdetail,';
	$str.=' a.ctag					as ctag,';
	$str.=' a.nstatus				as nstatus,';
	//$str.=' a.nnew				as nnew,';
	//$str.=' a.cflash				as cflash,';
	//$str.=' a.cfreeship				as cfreeship,';
	//$str.=' a.cnoi_bat				as cnoi_bat,';
	//$str.=' a.cbest_sell				as cbest_sell,';
	//$str.=' a.cthanh_ly				as cthanh_ly,';
	$str.=' a.ncheck				as ncheck,';
	//$str.=' a.nhethang				as nhethang,';
	$str.=' a.nhome				as nhome,';	
	
	$str.=' a.cindex				as cindex,';
	//$str.=' concat(b.cfirstname, " " , b.cmiddlename, " " , b.clastname)	as cfullname  ,	';	
	$str.=' a.niduser01				as niduser01 ,';
	$str.=' a.niduser02				as niduser02 ,';
	$str.=' a.ddate01				as ddate01 ,';
	$str.=' a.ddate02				as ddate02 ';
	
	$str.=' FROM ' . Fget_ap_table('tmaterial_products') . ' as c, ';
	$str.=' '. Fget_ap_table('tcat_products') . ' as b ,';
	$str.=' '. Fget_ap_table('tproducts') . ' as a ';
	//$str.=' '. Fget_ap_table('tcat_products') . ' as d ';
	$str.=' WHERE a.nid is not null ';
	$str.=' AND a.nid_material_products = c.nid';
	$str.=' AND a.nid_cat_products = b.nid';
	//$str.=' AND a.nid_cat_products = d.nid';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}

function Vcustomer()
{
	$str=' (SELECT ';
	$str.=' a.nid					as nid ,';
	$str.=' a.ccode					as ccode,';
	$str.=' a.customerid			as customerid,';
	$str.=' a.cpassword				as cpassword,';
	$str.=' a.cemail				as cemail,';
	$str.=' a.chandphone			as chandphone,';	
	$str.=' a.cfirstname			as cfirstname,';
	$str.=' a.cmiddlename			as cmiddlename,';
	$str.=' a.clastname				as clastname,';
	$str.=' a.caddress				as caddress,';
	$str.=' a.nstatus				as nstatus,';
	$str.=' a.cdel					as cdel,';
	$str.=' a.niduser01				as niduser01 ,';
	$str.=' a.niduser02				as niduser02 ,';
	$str.=' a.ddate01				as ddate01 ,';
	$str.=' a.ddate02				as ddate02 ';
	
	$str.=' FROM ' . Fget_ap_table('tcustomer') . ' as a ';
	$str.=' WHERE a.cdel="0" '; 
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vorder_status()
{
	$str=' (SELECT ';
	$str.=' a.nid					as nid ,';
	$str.=' a.ccode					as ccode,';
	$str.=' a.corder_status			as corder_status,';
	$str.=' a.cnote					as cnote,';
	$str.=' a.cindex				as cindex,';
	$str.=' a.nstatus				as nstatus,';
	$str.=' a.niduser01				as niduser01 ,';
	$str.=' a.niduser02				as niduser02 ,';
	$str.=' a.ddate01				as ddate01 ,';
	$str.=' a.ddate02				as ddate02 ';
	
	$str.=' FROM ' . Fget_ap_table('torder_status') . ' as a ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}

function Vorder()
{
    $str = ' (SELECT ';
    $str .= ' a.nid					as nid ,';
    $str .= ' a.ccode					as ccode,';
	$str .= ' a.ccode_vtp					as ccode_vtp,';
	$str .= ' a.nsale					as nsale,';
	$str .= ' a.nid_code_sale					as nid_code_sale,';
    $str .= ' a.nid_order_status		as nid_order_status,';
    $str .= ' b.corder_status			as corder_status,';
    $str .= ' a.nid_customer			as nid_customer,';
    $str .= ' a.cfullname				as cfullname,';
    $str .= ' a.caddress				as caddress,';
	$str .= ' a.caddress_type				as caddress_type,';
	$str .= ' a.nid_ward				as nid_ward,';
	$str .= ' a.nid_district				as nid_district,';
	$str .= ' a.nid_province				as nid_province,';
    $str .= ' a.cemail				as cemail,';
    $str .= ' a.cphone				as cphone,';
    $str .= ' a.cnote					as cnote,';
    $str .= ' a.nstatus				as nstatus,';
    $str .= ' a.niduser01				as niduser01 ,';
    $str .= ' a.niduser02				as niduser02 ,';
    $str .= ' a.ddate01				as ddate01 ,';
	$str .= ' a.ctime01				as ctime01 ,';
	$str .= ' a.ctime				as ctime ,';
	$str .= ' a.ctime_search			as ctime_search,';
    $str .= ' a.utm_source				as utm_source, ';
	$str .= ' a.cmethod				as cmethod, ';
	$str .= ' a.ctype				as ctype, ';
	$str .= ' a.vnp_TransactionStatus				as vnp_TransactionStatus, ';
    $str .= ' a.ddate02				as ddate02 ';
    $str .= ' FROM ' . Fget_ap_table('torder') . ' as a ,';
    $str .= '  ' . Fget_ap_table('torder_status') . ' as b ';
    $str .= ' WHERE a.nid is not null ';
    $str .= ' AND a.nid_order_status = b.nid';
    $str .= ' ) ';
    $str .= ' as view ';
    return $str;
}
/*
function Vbrand_product()
{
	$str=' (SELECT ';
	$str.=' a.nid					as nid ,';
	$str.=' a.ccode					as ccode,';
	$str.=' a.cbrand_products		as cbrand_products,';
	$str.=' b.nid					as nid_cat_products,';
	$str.=' b.ccat_products			as ccat_products,';
	$str.=' c.nid					as nid_material_products,';
	$str.=' c.cmaterial_products	as cmaterial_products,';
	$str.=' a.cimage				as cimage,';
	$str.=' a.ctag					as ctag,';
	$str.=' a.cnote					as cnote,';
	$str.=' a.nstatus				as nstatus,';	
	$str.=' a.cindex				as cindex,';	
	$str.=' a.niduser01				as niduser01 ,';
	$str.=' a.niduser02				as niduser02 ,';
	$str.=' a.ddate01				as ddate01 ,';
	$str.=' a.ddate02				as ddate02 ';
	
	$str.=' FROM ' . Fget_ap_table('tbrand_products') . ' as a , ';
	$str.=' '. Fget_ap_table('tcat_products') . ' as b ,';
	$str.=' '. Fget_ap_table('tmaterial_products') . ' as c ';
	$str.=' WHERE a.nid is not null ';
	$str.=' AND a.nid_cat_products = b.nid';
	$str.=' AND a.nid_material_products = c.nid';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
*/
function Vcat_wood_view()
{
	$str=' (SELECT ';

	$str.=' a.nid					as nid ,';
	$str.=' a.ccat_news				as ccat_news,';
	$str.=' a.cnote					as cnote ,';
	$str.=' a.ccode					as ccode ,';
	$str.=' a.ctag					as ctag ,';	
	$str.=' a.nstatus				as nstatus ,';
	$str.=' a.cindex				as cindex ,';
	$str.=' a.niduser01				as nid_user01 ,';
	
	//$str.=' a.nid_section_news		as nid_section_news ,';
//	$str.=' d.csection_news			as csection_news ,';
	
	//$str.=' b.nid_org				as nid_org ,';
	//$str.=' b.nid_language			as nid_language,';
	//$str.=' b.nid_translate			as nid_translate,';
	//$str.=' b.ctbl_name				as ctbl_name,';
	
	//$str.=' c.clanguage				as clanguage,';
	$str.=' a.ddate01				as ddate01';
	$str.=' FROM ' . Fget_ap_table2('tcat_wood') . ' as a ' ;
	//$str.='      ' . Fget_ap_table2('ttranslate'). ' as b ,';
	////$str.='      ' . Fget_ap_table2('tlanguage') . ' as c, ';
//	$str.='      ' . Fget_ap_table2('tsection_news') . ' as d ';
	$str.=' WHERE a.nid 		is not null '; 
	//$str.=' AND   c.nid 		= b.nid_language'; 
	//$str.=' AND   d.nid 		= a.nid_section_news'; 
//	$str.=' AND   b.ctbl_name 		= "tcat_news"';
	$str.=') as view ';
	return $str;
}

function Vwood_view()
{
	$str ='(SELECT';
	$str.=' a.nid				as nid ,';
	$str.=' a.nid_cat_news		as nid_cat ,';
	$str.=' b.ccat_news			as ccat_news ,';
	$str.=' a.ctitle			as ctitle ,';
	$str.=' a.nimg				as nimg ,';
	$str.=' a.cindex			as cindex ,';
	$str.=' a.ctag				as ctag ,';
	$str.=' a.alwcmt			as alwcmt ,';
	$str.=' a.nstatus 			as nstatus ,';
	$str.=' a.nactive 			as nactive ,';
	$str.=' a.niduser01 		as niduser01 ,';
	$str.=' a.nid_section_news	as nid_section_news ,';
	$str.=' c.csection_news		as csection_news ,';	
	$str.=' a.ddate01 			as ddate01 ';

	$str.=' FROM ' . Fget_ap_table('tsection_wood') . ' as c	 ,';
	$str.= 		     Fget_ap_table('twood') . ' as a';
	$str.= ' LEFT JOIN '. Fget_ap_table('tcat_wood') . ' as b  ON (a.nid_cat_news = b.nid) ';
	//$str.= 				Fget_ap_table('ttranslate') . ' as d ,';
	//$str.= 				Fget_ap_table('tlanguage') . ' as e ';
	
	$str.=' WHERE 	a.nid is not null ';
	$str.=' AND 	a.nid_section_news 	= c.nid ';
	//$str.=' AND 	d.nid_language	  	= e.nid';
	//$str.=' AND 	d.nid_translate		= a.nid';
	//$str.=' AND 	d.ctbl_name 		= "tnews" ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vupload()
{
	$str=' (SELECT * ';
	$str.=' FROM ' . Fget_ap_table('tfiles') . ' as a  ';
	$str.=' WHERE a.nid is not null';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Varticle_view()
{
	$str=' (SELECT a.* ,';
	$str.=' concat(b.cfirstname, " " , b.cmiddlename, " " , b.clastname)	as cfullname ';	
	$str.=' FROM ' . Fget_ap_table('tarticle') . ' as a , ';
	$str.=  Fget_ap_table('tuser') .' as b ';
	$str.=' WHERE a.nid is not null ';
	$str.=' AND a.niduser01 = b.nid ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vcode_sale_view()
{
	$str=' (SELECT a.* ';
	$str.=' FROM ' . Fget_ap_table('tcode_sale') . ' as a  ';
	$str.=' WHERE a.nid is not null ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vcolor_view()
{
	$str=' (SELECT a.* ';
	$str.=' FROM ' . Fget_ap_table('tcolor') . ' as a  ';
	$str.=' WHERE a.nid is not null ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vtv_view()
{
	$str=' (SELECT a.* ';
	$str.=' FROM ' . Fget_ap_table('tvideo') . ' as a  ';
	$str.=' WHERE a.nid is not null ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vtv_cat_view()
{
	$str=' (SELECT a.* ';
	$str.=' FROM ' . Fget_ap_table('tvideo_cat') . ' as a  ';
	$str.=' WHERE a.nid is not null ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vproduct_bid_view()
{
	$str=' (SELECT a.* ';
	$str.=' FROM ' . Fget_ap_table('tproduct_bid') . ' as a  ';
	$str.=' WHERE a.nid is not null ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vproduct_bid_log_view()
{
	$str=' (SELECT a.* ';
	$str.=' FROM ' . Fget_ap_table('tproduct_bid_log') . ' as a  ';
	$str.=' WHERE a.nid is not null ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vmember_view()
{
	$str=' (SELECT a.* ';
	$str.=' FROM ' . Fget_ap_table('tmember') . ' as a  ';
	$str.=' WHERE a.nid is not null ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vbot_view()
{
	$str=' (SELECT a.* ';
	$str.=' FROM ' . Fget_ap_table('tmember') . ' as a  ';
	$str.=' WHERE a.nid is not null ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vbid_win_view()
{
	$str=' (SELECT a.*,';
	$str.=' b.cname					as cname,';
	$str.=' b.cid					as cid,';
	$str.=' b.ctype					as ctype,';
	$str.=' c.cproducts		as cproducts';

	$str.=' FROM ' . Fget_ap_table('tbid_win') . ' as a , ';
	$str.=' '. Fget_ap_table('tmember') . ' as b ,';
	$str.=' '. Fget_ap_table('tproducts') . ' as c, ';
	$str.=' '. Fget_ap_table('tproduct_bid') . ' as d ';
	$str.=' WHERE a.nid is not null ';
	$str.=' AND a.nid_member = b.nid';
	$str.=' AND a.nid_product = c.nid';
	$str.=' AND a.nid_product_bid = d.nid';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vcomment_view()
{
	$str=' (SELECT a.*, b.cproducts as cproducts ';
	$str.=' FROM ' . Fget_ap_table('tcomment') . ' as a,  ';
	$str.=  Fget_ap_table('tproducts') .' as b ';
	$str.=' WHERE a.nid is not null ';
	$str.=' AND a.nid_product = b.nid ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vrating_view()
{
	$str=' (SELECT a.*, b.cproducts as cproducts ';
	$str.=' FROM ' . Fget_ap_table('trating') . ' as a,  ';
	$str.=  Fget_ap_table('tproducts') .' as b ';
	$str.=' WHERE a.nid is not null ';
	$str.=' AND a.nid_product = b.nid ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vreply_view()
{
	$str=' (SELECT a.* ';
	$str.=' FROM ' . Fget_ap_table('treply') . ' as a  ';
	$str.=' WHERE a.nid is not null ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vapi_key_view()
{
	$str=' (SELECT a.* ';
	$str.=' FROM ' . Fget_ap_table('keys') . ' as a  ';
	//$str.=' WHERE a.nid is not null ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vregister_view()
{
	$str=' (SELECT a.* ';
	$str.=' FROM ' . Fget_ap_table('tregister') . ' as a  ';
	$str.=' WHERE a.nid is not null ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vuser_type_view()
{
	$str=' (SELECT a.* ';
	$str.=' FROM ' . Fget_ap_table('tuser_type') . ' as a  ';
	$str.=' WHERE a.nid is not null ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vbrand_product()
{
	$str=' (SELECT a.* ';
	$str.=' FROM ' . Fget_ap_table('tbrand_products') . ' as a  ';
	$str.=' WHERE a.nid is not null ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vsetting_view()
{
	$str=' (SELECT a.* ';
	$str.=' FROM ' . Fget_ap_table('tsetting') . ' as a  ';
	$str.=' WHERE a.nid is not null ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vflashsale_view()
{
	$str=' (SELECT a.* ';
	$str.=' FROM ' . Fget_ap_table('tflashsale') . ' as a  ';
	$str.=' WHERE a.nid is not null ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vgroup_product_view()
{
	$str=' (SELECT a.* ';
	$str.=' FROM ' . Fget_ap_table('tgroup_product') . ' as a  ';
	$str.=' WHERE a.nid is not null ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}
function Vgallery_img()
{
	$str=' (SELECT a.* ';
	$str.=' FROM ' . Fget_ap_table('tgallery_img') . ' as a  ';
	$str.=' WHERE a.nid is not null ';
	$str.=' ) ';
	$str.=' as view ';
	return $str;
}