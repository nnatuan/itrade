<?php 
	$this->load->view('header');
	$this->load->view('header_end');
	$this->load->view('modules/mod_header'); 
?>
<form name="frm_system_log" id="frm_system_log" method="post" action="<?php echo $link_page; ?>">
    <div class="right_col" role="main">
        <div class="">
            <div class="clearfix"></div>

            <div class="row">
                <div class="col-md-12 col-sm-12">
                    <div class="x_panel">
                        <div class="x_title">
                            <h2><i class="fa fa-shield"></i> <?php echo $lbl_form_title; ?></h2>
                            <ul class="nav navbar-right panel_toolbox">
                                <li><a class="collapse-link"><i class="fa fa-chevron-up"></i></a></li>
                            </ul>
                            <div class="clearfix"></div>
                        </div>
                        <div class="x_content">
                            
                            <div class="table-responsive">
                                <table class="table table-striped table-bordered jambo_table bulk_action">
                                    <thead>
                                        <tr>
                                             <th class="qcare-th-center qcare-th-stt">#</th>
                                             <th class="qcare-th-code" style="width: 130px;">Người thao tác</th>
                                             <th class="qcare-th-center" style="width: 120px;">Hành động</th>
                                             <th class="qcare-th-center" style="width: 150px;">Bảng tác động</th>
                                             <th class="qcare-th-center" style="width: 100px;">ID dòng</th>
                                             <th>Nội dung chi tiết thay đổi (JSON Log)</th>
                                             <th class="qcare-th-center" style="width: 130px;">Địa chỉ IP</th>
                                             <th class="qcare-th-center" style="width: 140px;">Thời gian tạo</th>
                                        </tr>
                                    </thead>
                                    <tbody>

                                        <tr class="filter qcare-filter-row">
                                            <td class="text-center">
                                                <input name="btn_filter" type="button" class="btn btn-success btn-xs qcare-btn-filter-submit" value="Lọc" 
                                                    onclick="js_SetSubmitButtonClick(this.form, this.name);" />
                                            </td>
                                            <td> 
                                                <input name="txtf_cuserid" type="text" class="form-control input-sm" value="<?php echo isset($txtf_cuserid) ? $txtf_cuserid : ''; ?>" placeholder="Lọc Username..." />					
                                            </td>
                                            <td>
                                                <select name="cbof_caction" class="form-control input-sm" onchange="js_SetSubmitButtonClick(this.form, 'btn_filter');">
                                                    <option value="">-- Tất cả --</option>
                                                    <?php /*<option value="LOGIN" <?php echo (isset($cbof_caction) && $cbof_caction == 'LOGIN') ? 'selected' : ''; ?>>LOGIN</option>*/ ?>
                                                    <option value="INSERT" <?php echo (isset($cbof_caction) && $cbof_caction == 'INSERT') ? 'selected' : ''; ?>>INSERT</option>
                                                    <option value="UPDATE" <?php echo (isset($cbof_caction) && $cbof_caction == 'UPDATE') ? 'selected' : ''; ?>>UPDATE</option>
                                                    <option value="DELETE" <?php echo (isset($cbof_caction) && $cbof_caction == 'DELETE') ? 'selected' : ''; ?>>DELETE</option>
                                                </select>
                                            </td>
                                            <td>
                                                <input name="txtf_ctable_name" type="text" class="form-control input-sm" value="<?php echo isset($txtf_ctable_name) ? $txtf_ctable_name : ''; ?>" placeholder="Ví dụ: tbot_client..." />
                                            </td>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                        </tr> 
                                    
                                        <?php 
                                            if (isset($data_view) && is_array($data_view) && !empty($data_view)):
                                                $i = ($txt_current_page - 1) * $txt_row_per_page + 1; 
                                                foreach($data_view as $data):
                                                    $d_create = ($data['ddate_created'] != '') ? date('d/m/Y H:i:s', strtotime($data['ddate_created'])) : '-';
                                                    
                                                    // Đổ màu label tương ứng cho từng hành động
                                                    $lbl_class = "label-default";
                                                    // if($data['caction'] == "LOGIN")  $lbl_class = "label-info";
                                                    if($data['caction'] == "INSERT") $lbl_class = "label-success";
                                                    if($data['caction'] == "UPDATE") $lbl_class = "label-warning";
                                                    if($data['caction'] == "DELETE") $lbl_class = "label-danger";
                                        ?>
                                          <tr class="even pointer">
                                             <td class="text-center"><?php echo $i; ?></td>
                                             <td class="text-left">
                                                 <i class="fa fa-user"></i> <strong><?php echo $data['cuserid']; ?></strong><br>
                                                 <small class="text-muted"><?php echo Fview_text($data['cfullname']); ?></small>
                                             </td>
                                             <td class="text-center">
                                                 <span class="label <?php echo $lbl_class; ?>" style="font-size: 11px; font-weight: bold; letter-spacing: 0.5px;"><?php echo $data['caction']; ?></span>
                                             </td>
                                             <td class="text-center"><code style="font-size: 12px; color: #337ab7;"><?php echo $data['ctable_name']; ?></code></td>
                                             <td class="text-center text-dark" style="font-weight: bold;"><?php echo $data['nrecord_id']; ?></td>
                                             <td class="text-left" style="max-width: 450px; word-break: break-all;">
                                                 <small class="text-dark" style="font-family: Consolas, Monaco, monospace; font-size: 11px; display: block; max-height: 60px; overflow-y: auto; background: #fdfdfd; padding: 4px; border: 1px solid #eee; border-radius: 4px;">
                                                     <?php echo Fview_text($data['ccontent_log']); ?>
                                                 </small>
                                             </td>
                                             <td class="text-center"><small class="text-muted" style="font-weight: bold;"><i class="fa fa-laptop"></i> <?php echo ($data['cip_address'] != '') ? $data['cip_address'] : '127.0.0.1'; ?></small></td>
                                             <td class="text-center" style="font-size: 12px; color: #444; font-weight: 500;"><?php echo $d_create; ?></td>
                                          </tr>
                                        <?php 
                                                $i++; 
                                                endforeach;
                                            else: 
                                        ?>
                                          <tr>
                                             <td colspan="8" class="text-center" style="font-style: italic; color: #73879C; padding: 30px;">
                                                <i class="fa fa-info-circle"></i> Chưa ghi nhận nhật ký thao tác nghiệp vụ nào trên hệ thống.
                                             </td>
                                          </tr>
                                        <?php endif; ?>
                                    </tbody>
                                </table>
                            </div>
                            
                            <table class="table qcare-table-pagination" cellspacing="1">
                                <tr>						
                                    <td></td>
                                    <td class="qcare-pagination-block">
                                        <div class="form-inline pull-right">	
                                            <label class="qcare-row-per-page-label"><?php echo $lbl_rows_per_page; ?>:</label>&nbsp;
                                            <input class="form-control text-center input-sm qcare-page-input" name="txt_row_per_page" type="text" size="5" value="<?php echo $txt_row_per_page; ?>" />&nbsp;
                                            <input name="btn_row_per_page" type="button" value="<?php echo $btn_choose; ?>" onclick="js_SetSubmitButtonClick(this.form, this.name);" class="btn btn-default btn-sm" />
                                        </div>
                                    </td>
                                    <td class="qcare-pagination-block">
                                        <div class="form-inline pull-right">		
                                            <?php if($txt_current_page > 1): ?>
                                            <input class="btn btn-default btn-sm" name="btn_previous" type="button" value="<<" onclick="js_SetSubmitButtonClick(this.form, 'btn_previous');"/>&nbsp;	
                                            <?php endif; ?>
                                            
                                            <label class="qcare-page-indicator"><?php echo $txt_current_page . ' / ' . $txt_total_page; ?></label>&nbsp;
                                            
                                            <?php if($txt_current_page < $txt_total_page): ?>
                                            <input class="btn btn-default btn-sm" name="btn_next" type="button" value=">>" onclick="js_SetSubmitButtonClick(this.form, 'btn_next');"/>&nbsp;
                                            <?php endif ?>
                                                    
                                            <input class="form-control text-center input-sm qcare-page-input page-num" name="txt_current_page" type="text" value="<?php echo $txt_current_page; ?>" size="5" />&nbsp;
                                                   
                                            <input name="btn_page_number" type="button" value="<?php echo $btn_choose; ?>" onclick="js_SetSubmitButtonClick(this.form, this.name);" class="btn btn-default btn-sm" />
                                        </div>	
                                    </td>
                                </tr>					
                            </table>
                            
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <input type="hidden" name="hidden_button" id="hidden_button"/>
    <input name="hidden_nid" type="hidden" value="0" />
    <input name="hidden_event" type="hidden" value="<?php echo $event; ?>" />
</form>
<?php
	$this->load->view('modules/mod_footer');
	$this->load->view('footer');
?>