Y.use('jquery-noconflict', function (Y) {

(function ($) {
	$.extend({
		getCustomQuerystring: function(url, name){
		  url = url.replace(new RegExp('&amp;', 'g'),'&');
		  name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
		  var regexS = "[\\?&]" + name + "=([^&#]*)";
		  var regex = new RegExp(regexS);
		  var results = regex.exec(url);
		  if(results == null)
			return "";
		  else
			return decodeURIComponent(results[1].replace(/\+/g, " "));
		}
	});
})(jQuery);

/* amazon pay code here */
var default_path = "https://www2.heart.org";
jQuery(document).ready(function(){
  if (location.href.indexOf("dev2") > 0) {
    default_path = "https://dev2.heart.org";
  }
  if (location.href.indexOf("pg=personal") > 0 || location.href.indexOf("pg=team") > 0) {
		addPaymentOptions();
	}
	if (location.href.indexOf("pagename=heartwalk_participant_center") > 0) {
		addPCPaymentOptions();
	}
	if (location.href.indexOf("Donation2") > 0) {
		if (jQuery.getCustomQuerystring(location.href,"paypal") == "true") {
			setTimeout(function(){jQuery('label[for=responsive_payment_typepay_typeradiopaypal]').trigger('click');},2000);
		}
	}
});

function addPaymentOptions() {
	if (jQuery('a#sidebar_donate_button').length > 0) {
		var fr_id = jQuery.getCustomQuerystring(location.href,"fr_id");
		var teamid = jQuery.getCustomQuerystring(location.href,"team_id");
		var px = jQuery.getCustomQuerystring(location.href,"px");
    
    		/* personal page */
		if (jQuery('body.pg_personal').length > 0) {
			var dlink = jQuery('a#sidebar_donate_button').attr("href");
			var html = "<div class='paymentSelType text-center hidden'><h3>How would you like to donate?</h3>" +
  				"<a href='"+dlink+"'><img src='https://www2.heart.org/images/content/pagebuilder/credit-card-logos2.png' alt='Donate with Visa, MasterCard, American Express or Discover cards' style='width: 90%; margin: .3em auto;'/></a>" +
  				"<a href='"+default_path+"/site/SPageNavigator/heartchase_donate_amazon.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE=20' class='amazon'><img src='https://www2.heart.org/images/content/pagebuilder/amazon-payments.png' alt='Donate with Amazon Pay' style='width: 90%; margin: .3em auto;'/></a>" +
  				"<a href='"+default_path+"/site/SPageNavigator/heartchase_donate_googlepay.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE=20' class='googlepay'><img src='https://www2.heart.org/donation-forms/donatenow/images/googlepay-button.png' alt='Donate with Google Pay' style='width: 90%; margin: .3em auto;'/></a>" +
				"<a href='"+default_path+"/site/SPageNavigator/heartchase_donate_applepay.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE=20' class='applepay hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms-braintree/donatenow/images/DonateBlack_32pt_@2x.png' alt='ApplePay' style='width: 90%; margin: .3em auto;'/></a>" +
				"<a href='"+default_path+"/site/SPageNavigator/heartchase_donate_venmo.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE=20' class='venmo hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms/donatenow/images/venmo-button.png' alt='Venmo' style='width: 90%; margin: .3em auto;'/></a>" +
			    	"<a href='"+dlink+"&paypal=true'><img src='https://www2.heart.org/images/content/pagebuilder/PP_logo_h_100x26.png' alt='Donate with PayPal'  style='margin: .3em auto;' /></a>";
			jQuery('a#sidebar_donate_button').closest('div').after(html);
			jQuery('a#sidebar_donate_button').click(function(){
				jQuery('#personal_page_menu > div.paymentSelType').removeClass('hidden');
				jQuery('.side-bar .paymentSelType').slideDown();
				return false;
			});
			jQuery('a#main_donate_button').closest('div').after(html);
			jQuery('a#main_donate_button').click(function(){
				jQuery('#personal_page_main_content > div.paymentSelType').removeClass('hidden');
				jQuery('#personal_page_main_content .paymentSelType').slideDown();
				return false;
			});
		}

    		/* team page */
		if (jQuery('body.pg_team').length > 0) {
			var dlink = jQuery('a#sidebar_donate_button').attr("href");
  			var html = "<div class='paymentSelType text-center hidden'><h3>How would you like to donate?</h3>"+
		  			"<a href='"+dlink+"'><img src='https://www2.heart.org/images/content/pagebuilder/credit-card-logos2.png' alt='Donate with Visa, MasterCard, American Express or Discover cards'/></a>" +
		  			"<a href='"+default_path+"/site/SPageNavigator/heartchase_donate_amazon.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+teamid+"&PROXY_TYPE=22' class='amazon'><img src='https://www2.heart.org/images/content/pagebuilder/amazon-payments.png' alt='Donate with Amazon Pay'/></a>" +
 	  				"<a href='"+default_path+"/site/SPageNavigator/heartchase_donate_googlepay.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+teamid+"&PROXY_TYPE=22' class='googlepay'><img src='https://www2.heart.org/donation-forms/donatenow/images/googlepay-button.png' alt='Donate with Google Pay'/></a>" +
					"<a href='"+default_path+"/site/SPageNavigator/heartchase_donate_applepay.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+teamid+"&PROXY_TYPE=22' class='applepay hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms-braintree/donatenow/images/DonateBlack_32pt_@2x.png' alt='ApplePay'/></a>" +
					"<a href='"+default_path+"/site/SPageNavigator/heartchase_donate_venmo.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+teamid+"&PROXY_TYPE=22' class='venmo hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms/donatenow/images/venmo-button.png' alt='Venmo'/></a>" +
		  			"<a href='"+dlink+"&paypal=true'><img src='https://www2.heart.org/images/content/pagebuilder/PP_logo_h_100x26.png'/ alt='Donate with PayPal'></a>" +
		    		 "</div>";
			jQuery('a#sidebar_donate_button').closest('div').after(html);
			jQuery('a#sidebar_donate_button').click(function(){
				jQuery('#team_page > div.side-bar > div.paymentSelType').removeClass('hidden');
				jQuery('.side-bar .paymentSelType').slideDown();
				return false;
			});
			jQuery('a#main_donate_button').closest('div').after(html);
			jQuery('a#main_donate_button').click(function(){
				jQuery('#team_page_main_content > div.paymentSelType').removeClass('hidden');
				jQuery('#team_page_main_content .paymentSelType').slideDown();
				return false;
			});
		}
	} else {
		setTimeout(addPaymentOptions,500);
	}
}

function addPCPaymentOptions() {
	if (jQuery('a#make_a_donation').length > 0) {
		var fr_id = jQuery.getCustomQuerystring(location.href,"fr_id");
		var teamid = jQuery.getCustomQuerystring(location.href,"team_id");
		var px = jQuery.getCustomQuerystring(location.href,"px");
	  
		if (location.href.indexOf("pagename=heartwalk_participant_center") > 0) {
		 	jQuery('.profile_box_row').css({"display":"flex"});
			var dlink = jQuery('a#make_a_donation').attr("href");
			var px = jQuery('body').data("cons-id");
			var html = "<div class='paymentSelType hidden' style='clear:both;padding-top:20px;'>" +
						 "<h7>How would you like to donate?</h7>" +
						 "<a href='"+dlink+"'><img src='https://www2.heart.org/images/content/pagebuilder/credit-card-logos2.png' alt='Donate with Visa, MasterCard, American Express or Discover cards'/></a>" +
						 "<a href='"+default_path+"/site/SPageNavigator/heartchase_donate_amazon.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE=20' class='amazon'><img src='https://www2.heart.org/images/content/pagebuilder/amazon-payments.png' alt='Donate with Amazon Pay'/></a>" +
						 "<a href='"+default_path+"/site/SPageNavigator/heartchase_donate_googlepay.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE=20' class='googlepay'><img src='https://www2.heart.org/donation-forms/donatenow/images/googlepay-button.png' alt='Donate with Google Pay'/></a>" +
						 "<a href='"+default_path+"/site/SPageNavigator/heartchase_donate_applepay.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE=20' class='applepay hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms-braintree/donatenow/images/DonateBlack_32pt_@2x.png' alt='ApplePay'/></a>" +
						 "<a href='"+default_path+"/site/SPageNavigator/heartchase_donate_venmo.html?FR_ID="+fr_id+"&mfc_pref=T&PROXY_ID="+px+"&PROXY_TYPE=20' class='venmo hidden-md hidden-lg'><img src='https://www2.heart.org/donation-forms/donatenow/images/venmo-button.png' alt='Venmo'/></a>" +
						 "<a href='"+dlink+"&paypal=true'><img src='https://www2.heart.org/images/content/pagebuilder/PP_logo_h_100x26.png'/ alt='Donate with PayPal'></a>" +
						 "</div>";
			jQuery('a#make_a_donation').closest('.profile_box').append(html);
			jQuery('a#make_a_donation').click(function(e){
				e.preventDefault();
				jQuery('#personal_page_main_content > div.paymentSelType').removeClass('hidden');
				jQuery('.paymentSelType').slideDown();
				return false;
			});		  
		}

	} else {
		setTimeout(addPCPaymentOptions,500);
	}
}
});
