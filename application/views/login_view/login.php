<div style="width:300px;margin:auto;font-weight:bold;text-align:center;font-family:'Courier New', Courier, monospace;font-size:24px;color:#333;padding-top:100px;">CMS ADMINISTRATOR</div>
<form action=<?php echo $link_page; ?> method="post" name="form_main" >
<div id="login">
	<div class="module_round login_form" style="margin-bottom:5px;width:300px;" >
		<div class="module_top">
			<div class="module_top_left_bg"></div>
			<div class="module_top_center_bg"></div>
			<div class="module_top_right_bg"></div>
		</div>
		<div class="module_content">
			<h3 class="module_title"><?php echo $lbl_form_title; ?></h3>
			<div style="padding:10px 10px 5px 10px;">
				<div style="color:#FF0000; text-align:center" >
					<?php
						if(trim($error_message)!='')
							echo $error_message;
					?>
				</div>
				<div class="tkn_module_row">
					<div style="width:100px;">
						<label><?php echo $lbl_user_name ?>:</label>
					</div>
					<div>
						<input type="text" name="txt_user_name" 
								value="<?php echo $txt_user_name; ?>" 
								id="user_name" style="width:150px;" 
								alt="User login" />
					</div>
				</div>
				<div class="tkn_module_row">
					<div style="width:100px;">
						<label><?php echo $lbl_password ?>:</label>
					</div>
					<div>
						<input type="password" name="txt_password" value="<?php echo $txt_password?>" id="password" style="width:150px;" />
					</div>
				</div>
				<div style="padding:10px 0 0 100px;overflow:hidden;">
					<input type="submit" name="btn_login" value = "<?php echo $btn_login ?>" 
							onclick ="js_SetSubmitButtonClick(this.form, this.name);" class="button" style="width:120px"/>
				</div>
				
				<!--<div style="margin-top:30px;text-align:center;">
					<a href="<?php //echo base_url().'index.php/do_forget_password' ?>"><?php echo $lbl_forget;?></a>
				</div>-->
			</div>
		</div>
		<div class="module_footer">
			<div class="module_footer_left_bg"></div>
			<div class="module_footer_center_bg"></div>
			<div class="module_footer_right_bg"></div>
		</div>
	</div>
	<input type="hidden" name="hidden_event_index"  value = "" />
	</form>
</div>

<script type="text/javascript" >
	document.form_main.txt_user_name.focus();

function js_VerifyBeforeSubmit (obj_form, btn_name) 
	{
		if (document.form_main.txt_user_name.value=='')
			{
				document.form_main.txt_user_name.focus();
				return false;
			}
		if (document.form_main.txt_password.value=='')
			{
				document.form_main.txt_password.focus();
				return false;
			}
		return false;		
	}		

/*-------------------------------------------------------------------------------------
* Tokaban Corp 2009
* Package : TKB PHP SYSTEM CODE
*--------------------------------------------------------------------------------------
* huanlv77 - 2009/06/28.
*--------------------------------------------------------------------------------------
* Ham submit form co su dung su kien hidden de truyen bien flag dieu khien.
* Nhiem vu gan gia tri cho bien hidden dieu khien nut nhan submit cua form.
* Dung de controller nhan biet nut submit nao duoc nhan tren giao dien de xu ly tren server script.
* Ham nay duoc dung chung cho toan bo ung dung.
* Nen xay dung thanh chuan de tai su dung cho nhung du an khac.
*--------------------------------------------------------------------------------------*/
function js_SetSubmitButtonClick(obj_form, btn_name) 
	{
		obj_form.hidden_event_index.value=btn_name;
		obj_form.submit();		
	}		
</script>