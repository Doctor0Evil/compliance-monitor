; ALN Script: Email Data Structure for Compliance/Offer Parsing (paste.txt)
; ===========================================================================
; This logic loads, parses, and indexes the attached Microsoft Store email sample,
; prepares for campaign audits, privacy handling, and promotional compliance.

(defun load-microsoftstore-email ()
  '(:metadata
    (:message_id "<AC7000000006FBB52561C421371mscom_mkt_prod127@microsoftstore4.microsoft.com>"
     :created_at "Thu, Sep 4, 2025 at 11:49 AM"
     :from "Microsoft Store <Microsoftstore@microsoftstore.microsoft.com>"
     :to "xboxteejaymcfarmer@gmail.com"
     :subject "Save up to $500 on select Surface Laptop Copilot+ PCs"
     :spf "PASS"
     :dkim "PASS"
     :dmarc "PASS"
     :audit_flags "email authentic, not spoofed"))

  '(:delivery_headers
    (:received_ips ["172.82.209.165" "2002:a05:6638:c10d:b0:50e:ce11:3c7"]
     :tls_version "TLS1_2"))

  '(:content_brief
    (:headline "Save up to $500"
     :offers ["Trade-in Windows 10 PC for cash-back + Microsoft 365 trial"
              "Up to 28% savings on Certified Refurbished devices"
              "Students/Educators get up to 10% off"
              "Limited time offers on Surface Copilot+ PCs/Laptops"
              "Powerful meets portable: Surface Laptop/Pro flexibility"
              "Surface Copilot+ compatibility with school/work"
              "Free shipping, free returns, flexible payment options"])
    :region_restriction "US/Puerto Rico only"
    :disclaimer "Offers valid while supplies last; see Store Trade-in Program for details"
    :privacy_links ["Privacy Statement" "Unsubscribe"]
    :business_address "Microsoft Corporation, One Microsoft Way, Redmond, WA 98052"))

  '(:audit_compliance
    (:transaction_integrity "Valid"
     :promo_code_links ["https://t127.microsoftstore.-..."]
     :security_trackers ["https://cam-pixel-tracker-prod.azure-api.net/api/p127/track.png"]))

  '(:attachments
    (:original_file "paste.txt" :path "/opt/data/paste.txt")))
)

(load-microsoftstore-email)
