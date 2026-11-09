
/*-------------------------------------------------------------------------------------
* Tokaban Corp 2009
* Package : TKB PHP SYSTEM CODE
*--------------------------------------------------------------------------------------
*  - 2009/06/28.
*--------------------------------------------------------------------------------------
* Ham submit form co su dung su kien hidden de truyen bien flag dieu khien.
* Nhiem vu gan gia tri cho bien hidden dieu khien nut nhan submit cua form.
* Dung de controller nhan biet nut submit nao duoc nhan tren giao dien de xu ly tren server script.
* Ham nay duoc dung chung cho toan bo ung dung.
* Nen xay dung thanh chuan de tai su dung cho nhung du an khac.
*--------------------------------------------------------------------------------------*/
function js_SubmitButtonClick(obj_form, btn_name) 
	{
		obj_form.hidden_button.value=btn_name;
		obj_form.submit();
	}
	
function js_SetSubmitButtonClick(obj_form, btn_name) 
	{
		obj_form.hidden_button.value=btn_name;
		obj_form.submit();		
	}
/*-------------------------------------------------------------------------------------
document.getElementById("hidden_button").value = btn_name;
		document.getElementById(obj_form).submit();		
* Tokaban Corp 2009
* Package : TKB PHP SYSTEM CODE
*--------------------------------------------------------------------------------------
*  - 2009/09/08.
*--------------------------------------------------------------------------------------
* Ham submit form co su dung su kien hidden de truyen bien flag dieu khien.
* Nhiem vu gan gia tri cho bien hidden dieu khien nut nhan submit cua form.
* Dung de controller nhan biet nut submit nao duoc nhan tren giao dien de xu ly tren server script.
* Ham nay duoc dung chung cho toan bo ung dung.
* Nen xay dung thanh chuan de tai su dung cho nhung du an khac.
*--------------------------------------------------------------------------------------*/
function js_SetHiddenParam(obj_form, btn_name) 
	{
		obj_form.hidden_button.value=btn_name;
		obj_form.submit();
	}

/*-------------------------------------------------------------------------------------
* Tokaban Corp 2009
* Package : TKB PHP SYSTEM CODE
*--------------------------------------------------------------------------------------
*  - 2009/09/08.
*--------------------------------------------------------------------------------------
* Ham nay duoc dung chung cho toan bo ung dung.
* Nen xay dung thanh chuan de tai su dung cho nhung du an khac.
* Chi su dung cho cac doi tuong checkbox ma thoi.
* Yeu cau class cua cac checkbox phai dat theo chuan, dac thu theo tung nhom checkbox tuong ung tren form
*--------------------------------------------------------------------------------------*/
function js_CheckAllClick( objCheckbox, strGroupName )
	{
		var inputlist = document.getElementsByTagName("input");
		
  		for (var i = 0; i < inputlist.length; i++) 
		{				
   			if ( inputlist[i].getAttribute("type") == 'checkbox' )
			{
				if( inputlist[i].getAttribute("id") == strGroupName)
				{ 	
					inputlist[i].checked = objCheckbox.checked;
				}
			}
		}
	}
function js_CheckAllClick_2( objCheckbox, strGroupName ) //theo class
	{
		var inputlist = document.getElementsByTagName("input");
		
  		for (var i = 0; i < inputlist.length; i++) 
		{				
   			if ( inputlist[i].getAttribute("type") == 'checkbox' )
			{
				//if( inputlist[i].getElementsByClassName("class") == strGroupName) //ko ăn
				if( inputlist[i].getElementsByClassName(strGroupName))
				{ 	
					inputlist[i].checked = objCheckbox.checked;
				}
			}
		}
	}	
/*-------------------------------------------------------------------------------------
* Tokaban Corp 2009
* Package : TKB PHP SYSTEM CODE
*--------------------------------------------------------------------------------------
*  - 2009/09/08.
*--------------------------------------------------------------------------------------
* Ham nay duoc dung chung cho toan bo ung dung.
* Nen xay dung thanh chuan de tai su dung cho nhung du an khac.
* Chi su dung cho cac doi tuong checkbox ma thoi.
* Yeu cau class cua cac checkbox phai dat theo chuan.
* Doi tuong check vua click.
*--------------------------------------------------------------------------------------*/
function js_CheckItemClick( objCheckItem, strToggleName, strGroupName )
	{
		var inputlist = document.getElementsByTagName("input");
		var objToggleCheckbox;
		var ToggleCheckStatus=true;
  		for (var i = 0; i < inputlist.length; i++) 
		{				
   			if ( inputlist[i].getAttribute("type") == 'checkbox' ) 
			{				
				if( inputlist[i].getAttribute("name") == strToggleName )
				{
					objToggleCheckbox = inputlist[i];
				}
				else
				{
					if( inputlist[i].getAttribute("id") == strGroupName)
					{
							
						if (inputlist[i].checked==false)
						{
							ToggleCheckStatus = false;
						}
					}					
				}
				
			}
		}
		objToggleCheckbox.checked = ToggleCheckStatus;
	}
function js_CheckItemClick_2( objCheckItem, strToggleName, strGroupName ) //theo class
	{
		var inputlist = document.getElementsByTagName("input");
		var objToggleCheckbox;
		var ToggleCheckStatus=true;
  		for (var i = 0; i < inputlist.length; i++) 
		{				
   			if ( inputlist[i].getAttribute("type") == 'checkbox' ) 
			{				
				if( inputlist[i].getAttribute("name") == strToggleName )
				{
					objToggleCheckbox = inputlist[i];
				}
				else
				{
					//if( inputlist[i].getAttribute("class") == strGroupName) //ko ăn
					if( inputlist[i].getElementsByClassName(strGroupName))
					{
							
						if (inputlist[i].checked==false)
						{
							ToggleCheckStatus = false;
						}
					}					
				}
				
			}
		}
		objToggleCheckbox.checked = ToggleCheckStatus;
	}
/*-------------------------------------------------------------------------------------
* Tokaban Corp 2009
* Package : TKB PHP SYSTEM CODE
*--------------------------------------------------------------------------------------
*  - 2009/09/14.
*--------------------------------------------------------------------------------------
* Ham nay duoc dung chung cho toan bo ung dung.
* Nen xay dung thanh chuan de tai su dung cho nhung du an khac.
* Chi su dung cho cac doi tuong checkbox ma thoi.
* Yeu cau class cua cac checkbox phai dat theo chuan.
* Kiem tra client da duoc hien cac dieu kien can thiet truoc khi thuc hien submit form.
* Kiem tra xem da co checkbox thong tin nao duoc click hay chua. 
* Neu da co thi confirm xac nhan truoc khi submit form den controller tuong ung.
*--------------------------------------------------------------------------------------*/
function js_CheckValidBeforeDeleteListview(objForm, strGroupName, strConfirmDelete, strInvalidDelete)
	{
		var inputlist = document.getElementsByTagName("input");		
		var c = false;
		for (var i = 0; i < inputlist.length; i++) 
		{				
			if ( inputlist[i].getAttribute("type") == 'checkbox' ) 
			{
				if( inputlist[i].getAttribute("id") == strGroupName)
				{
					if (inputlist[i].checked == true)
					{
						c = true;
					}
				}	
			}
		}
		
		if (c==true)
			{
				AnsertClick = confirm(strConfirmDelete);
				if (AnsertClick==true)
				{
					objForm.hidden_button.value='btn_delete';
					objForm.submit();
				}
			}
		else
			{					
				alert(strInvalidDelete);
			}
	}

function js_CheckValidBeforeDeleteListview2(objForm, strGroupName, strConfirmDelete, strInvalidDelete)
	{
		var inputlist = document.getElementsByTagName("input");
		var c = false;
		for (var i = 0; i < inputlist.length; i++) 
		{				
			if ( inputlist[i].getAttribute("type") == 'checkbox' ) 
			{
				if( inputlist[i].getAttribute("id") == strGroupName)
				{
					if (inputlist[i].checked == true)
					{
						c = true;
					}
				}	
			}
		}
		
		if (c==true)
			{
				AnsertClick = confirm(strConfirmDelete);
				if (AnsertClick==true)
				{
					objForm.hidden_button.value=strGroupName;
					objForm.submit();
				}
			}
		else
			{					
				alert(strInvalidDelete);
			}
	}

/*
---------------------------------------------------------------------------------------
* Tokaban Corp 2009
* Package : TKB PHP SYSTEM CODE
*--------------------------------------------------------------------------------------
*  - 2009/06/28.
*--------------------------------------------------------------------------------------
* 
*--------------------------------------------------------------------------------------
*/
function js_CheckClickDepartment( objform, ni, strGroupName ){	
	var inputlist = document.getElementsByTagName("input");
	var strItemValue='';
	
		for ( var i=0; i < inputlist.length; i++ )
		{
			if ( inputlist[i].getAttribute("type") == 'checkbox' )
			{
				if( inputlist[i].getAttribute("id") == strGroupName)
				{
					
					strItemValue = inputlist[i].getAttribute("value");
					
					if(strItemValue.substring(0,ni.value.length) == ni.value)
					{
						inputlist[i].checked = ni.checked;
					}
				}
			}
		}		
	}