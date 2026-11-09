
<div id="login_right">
	  <h3> <?php  echo $this->lang->line('lbl.logout.confirm') ?></h3>
	  <p><?php  echo $this->lang->line('lbl.logout.guide') ?></p>
	  <div id="control" style="text-align:left;padding-left:120px" >
		 <ul>
			<li class="control_button first">
				<a href="<?php echo base_url().'index.php/do_logout' ;?>">Logout</a>
			</li>
			<li class="control_button first" style="margin-left:20px">
				<a href="javascript:closebox('box')">Cancel</a>
			</li>
		</ul>		
	</div>
</div>

