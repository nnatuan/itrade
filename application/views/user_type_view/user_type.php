
<style>
input[type=checkbox] {
    margin: 0 5px 0 0;
	float: left;
}
label {
    float: left;
    line-height: 14px;
	clear: initial;
	margin: 0;
}
hr {
    margin: 10px 0;
}
</style>




<!-- page content -->
			<div class="right_col" role="main">
				<div class="">
					<div class="page-title">
						<div class="title_left">
							<h3><small></small></h3>
						</div>

						<div class="title_right">
							
						</div>
					</div>
					<div class="clearfix"></div>
					<div class="row">
						<div class="col-md-12 col-sm-12 ">
							<div class="x_panel">
								<div class="x_title">
									<h2>Thêm mới / chỉnh sửa</h2>
									<div class="clearfix"></div>
								</div>
								<div class="x_content">
									<br />
									<form name='form_main' method="post" action="<?php echo $link_page; ?>">
										<div class="item form-group">
											<label class="col-form-label col-md-2 col-sm-2 label-align">Tên <span class="required">*</span></label>
											<div class="col-md-8 col-sm-8 ">
												<input type="text" name="cuser_type" value="<?php echo $cuser_type; ?>" required="required" class="form-control ">
											</div>
										</div>
										<div class="item form-group">
											<label class="col-form-label col-md-2 col-sm-2 label-align">Ghi chú</label>
											<div class="col-md-8 col-sm-8 ">
												<textarea class="form-control" id="" name="cnote" style="height:100px;"><?php echo $cnote; ?></textarea>
											</div>
										</div>
										<div class="item form-group">
											<label class="col-form-label col-md-2 col-sm-2 label-align">Phân quyền <span class="required">*</span></label>
											<div class="col-md-8 col-sm-8 " style="padding-top: 10px;">
												<input name="chkItems" type="checkbox" id="all" class="checkbox" 
									   onclick="js_CheckAllClick_2(this,this.name);" value="1" <?php if($cfull==1) echo "checked"; ?> /> <label for="all"><strong>Toàn quyền</strong></label>
							<?php $i=1; $list = get_access_all(); $list2 = get_permission_by_user_type($nid); $nid_group = '';
							foreach($list as $data) { $str_chk = ''; //if($nid_group == '') $nid_group == $data['nid_group'];
								foreach($list2 as $check)
									if($check["nid_access"] == $data['nid']) 
										$str_chk = 'checked="checked"'; 
							?>
							
							<?php if($data['nid_group'] != $nid_group) { $nid_group = $data['nid_group'];?>	
							<div style="clear:both;"></div>
							<hr>
							<?php } ?>
							
							<div style="float:left;margin-right:5px;width:24%;"><input type="checkbox" id="item_<?php echo $data['nid']; ?>" class="chkItems checkbox" name="nid_access[]" value="<?php echo $data['nid']; ?>" <?php echo $str_chk; ?> onclick="js_CheckItemClick_2(this, 'chkItems','chkItems');" /> <label for="item_<?php echo $data['nid']; ?>"><?php echo $i.'. '. $data['cname']; ?></label></div>

							<?php $i++;} ?>
							<div style="clear:both;"></div>
											</div>
										</div>
										
										
										<div class="ln_solid"></div>
										<div class="item form-group">
											<div class="col-md-8 col-sm-8 offset-md-2">
												<button type="button" class="btn btn-primary" name="btn_submit" value ="<?php echo $btn_update; ?>" 
													onclick ="js_SetSubmitButtonClick(this.form, this.name);">Xác nhận</button>
												<button class="btn btn-danger" type="button" name="btn_cancel" value ="<?php echo $btn_cancel; ?>" 
													onclick ="location.href='<?php echo $link_cancel; ?> '">Quay về</button>
											</div>
										</div>
										<input name="hidden_nid" type="hidden" value = "<?php echo $nid; ?>"  />
										  <input name="hidden_event" type="hidden" value = "<?php echo $event; ?>"  />
										  <input type="hidden" name="hidden_button"  value = "" />

									</form>
								</div>
							</div>
						</div>
					</div>

					
				</div>
			</div>
			<!-- /page content -->