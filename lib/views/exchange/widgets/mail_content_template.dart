import 'package:intl/intl.dart';

getMailContentTemplate(
    {String? receiverName,
    String? requestCreatorName,
    String? requestName,
    String? communityName,
    required int startDate}) {
  return StringBuffer(
          """<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">

    <head>
        <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
    </head>
    
    <body>
        <div dir="ltr">
    
            <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: inherit;border:0px;background-color:white;font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif">
                <tbody>
    
                        <tr>
                        <td align="center valign="top" id="m_-637120832348245336m_6644406718029751392gmail-m_-5513227398159991865templateBody" style="background:none 50% 50%/cover no-repeat white;border-collapse:inherit;border:0px;border-color:white;padding-top:0px;padding-bottom:0px">
                            <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-left:10px;border-right:10px;border-top:10px;border-bottom:0px;padding:40px 80px 0px 80px;border-style:solid;border-collapse: seperate;border-color:#766FE0;max-width:600px;width:600px">
                                <tbody>
                                    
                                    <tr>
                                        <td align="center valign="top" id="m_-637120832348245336m_6644406718029751392gmail-m_-5513227398159991865templateHeader" style="background:none 50% 50%/cover no-repeat white;border-collapse:inherit;border:0px;border-color:white;padding-top:19px;padding-bottom:19px">
                                            <table align="left" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width:600px;width:600px">
                                                <tbody>
                                                    <tr>
                                                        <td valign="top" style="background-image:none;background-repeat:no-repeat;background-position:50% 50%;background-size:cover;border-collapse:inherit;border:0px;border-color:white;padding-top:0px;padding-bottom:0px">
                                                            <table border="0" cellpadding="0" cellspacing="0" width="100%" >
                                                                <tbody>
                                                                    <tr>
                                                                        <td valign="top" >
                                                                            <table align="left" width="100%" border="0" cellpadding="0" cellspacing="0" style="border-collapse:inherit;border:0px;border-color:white;">
                                                                                <tbody>
                                                                                    <tr>
                                                                                        <td valign="top" style="padding:0px;text-align:center"><img align="left" alt="" src="https://ci5.googleusercontent.com/proxy/KMTN5MCNI08J15B09izASZ49J6rqtQf7e39MXu2B9OeOXFLSrmcqMBLGqpRsiuXVXCs5K0VhqORlonSSzigT_LlYKqS9WLljenNftkN5gYij5IKg6WOJ3VGHj2YikF1RrzTnoKPBEXfJl5RtYCqCHQVcmNYZZQ=s0-d-e1-ft#https://mcusercontent.com/18ef8611cb76f33e8a73c9575/images/60fe9519-6fc0-463f-8c67-b6341d56cf6f.jpg"
                                                                                                width="108" style="margin-right:35px;border-collapse:inherit;border:0px;border-color:white;height:auto;outline:none;vertical-align:bottom;max-width:400px;padding-bottom:0px;display:inline" class="CToWUd"></td>
                                                                                    </tr>
                                                                                </tbody>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </td>
                                    </tr>
    
                                    <tr>
                                        <td valign="top" style="background-image:none;background-repeat:no-repeat;background-position:50% 50%;background-size:cover;border-collapse: inherit;border:0px;padding:0px">
                                            
                                        
                                            <table border="0" cellpadding="0" cellspacing="0" width="100%" style="min-width:100%;table-layout:fixed">
                                                <tbody>
                                                    <tr>
                                                        <td style="min-width:100%;padding:18px 10px 18px 0px">
                                                            <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: inherit;min-width:100%;border-top:2px solid rgb(234, 234, 234)">
                                                                <tbody>
                                                                    <tr>
                                                                        <td></td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                                <tbody>
                                                    <tr>
                                                        <td valign="top" style="padding-bottom:0px">
                                                            <table align="left" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: inherit;max-width:100%;min-width:100%">
                                                                <tbody>
                                                                    <tr>
                                                                        <td valign="top" style="font-family:Helvetica;word-break:break-word;font-size:16px;line-height:16px;padding:0px 4px 9px">
                                                                            <div style="text-align:left;font-size:18px;line-height:20px;font-weight:500;color:#2c2c2d;">Hi ${receiverName},</div>
                                                                            <div style="text-align:left;font-size:20px;line-height:25px;color:black;font-weight:700;"><br>You have been invited by ${requestCreatorName} to be a speaker \n on the topic of ${requestName} on ${DateFormat('EEEE, d').format(DateTime.fromMillisecondsSinceEpoch(startDate))} at ${DateFormat('MMM h:mm a').format(DateTime.fromMillisecondsSinceEpoch(startDate))}.</div>
                                                                        </td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td valign="top" style="padding-bottom:10px">
                                                            <table align="left" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: inherit;max-width:100%;min-width:100%">
                                                                <tbody>
                                                                    <tr>
                                                                        <td valign="top" style="font-family:Helvetica;word-break:break-word;font-size:16px;line-height:16px;padding:0px 4px 9px">
                                                                            <div style="text-align:left;font-size:20px;line-height:25px;color:black;font-weight:700;"><br>Please accept the invitation by clicking on the notification you will receive in the SevaX app.</div>
                                                                        </td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td valign="top" style="padding-bottom:10px">
                                                            <table align="left" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: inherit;max-width:100%;min-width:100%">
                                                                <tbody>
                                                                    <tr>
                                                                        <td valign="top" style="font-family:Helvetica;word-break:break-word;font-size:16px;line-height:16px;padding:0px 4px 9px">
                                                                            <br>
                                                                            <br>
                                                                            <div style="text-align:left;font-size:18px;line-height:20px;font-weight:500;color:#2c2c2d;">Regards,</div>
                                                                            <br>
                                                                            <div style="text-align:left;font-size:18px;line-height:20px;font-weight:500;color:#2c2c2d;">${communityName}</div>
                                                                            <br>
                                                                            <br>
                                                                            <br>
                                                                        </td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>

                                        </td>
                                    </tr>
    
                                </tbody>
                            </table>
                        </td>
                    </tr>
                        <td align="center" valign="top" id="m_-637120832348245336m_6644406718029751392gmail-m_-5513227398159991865templateBody" style="background:none 50% 50%/cover no-repeat white;border-collapse:inherit;border:0px;border-color:white;padding-top:0px;padding-bottom:0px">
                            <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-left:0px;border-right:0px;border-top:0px;border-bottom:0px;padding:0px 0px 0px 00px;border-style:solid;border-collapse: seperate;border-color:#766FE0;max-width:777px">
                                <tbody>
    
                                    <tr >
                                        <td align=" center " valign="top " id="m_-637120832348245336m_6644406718029751392gmail-m_-5513227398159991865templateFooter " style="background:none 50% 50%/cover no-repeat rgb(47,46,46);border:0px;padding-top:45px;padding-bottom:33px;">
                                            <table align="center " border="0 " cellpadding="0 " cellspacing="0 " width="100% " style="max-width:777px;width:777px ">
                                                <tbody>
                                                    <tr style="text-align: center;">
                                                        <td valign="top " style="background:none 50% 50%/cover no-repeat transparent;border:0px;padding-top:0px;padding-bottom:0px;padding-left:8%;padding-right: 8%;">
                                                            <table border="0 " cellpadding="0 " cellspacing="0 " width="100% " style="min-width:100%;table-layout:fixed;">
                                                                <tbody>
                                                                    <tr>
                                                                        <td style="text-align: center;">
                                                                            <table border="0 " cellpadding="0 " cellspacing="0 " width="100% " style="border-top: 2px solid rgb(80,80,80) ">
                                                                                <tbody>
                                                                                    <tr>
                                                                                        <td></td>
                                                                                    </tr>
                                                                                </tbody>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                            <table  border="0 " cellpadding="0 " cellspacing="0 " width="100%">
                                                                <tbody>
                                                                    <tr>
                                                                        <td valign="top " style="padding-top:9px;">
                                                                            <table align="center " border="0" cellpadding="0 " cellspacing="0 " width="100% " style="text-align: center !important;">
                                                                                <tbody>
                                                                                    <tr>
                                                                                <td valign="top " style="font-family:Helvetica;word-break:break-word;color:rgb(255,255,255);font-size:12px;line-height:18px;text-align:center !important;padding:0px 18px 9px">
                                                                                    <em>Copyright © 2021 Seva Exchange Corporation. All rights reserved.</em><br><br><strong>Feel free to contact us at:</strong><br><a href="mailto:contact@sevaexchange.com " style="color:rgb(255,255,255) "
                                                                                        target="_blank ">info@sevaexchange.com</a><br><br><a href="https://sevaxapp.com/PrivacyPolicy.html" target="_blank" style="color:rgb(255,255,255);">Privacy Policy&nbsp;</a>&nbsp;<br>
                                                                                </td>
                                                                                    </tr>
                                                                                </tbody>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </td>
                                    </tr>
    
                                </tbody>
                            </table>
                        </td>
    
                </tbody>
            </table>
        </div>
    </body>
  </html>

 """)
      .toString();
}
