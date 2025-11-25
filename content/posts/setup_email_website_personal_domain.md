+++
title = "Set up email hosting and a personal website on personal domain"
author = ["Alán F. Muñoz"]
date = 2025-11-24T19:38:00-05:00
tags = ["email", "dns", "hosting", "smallweb", "github", "pages"]
categories = ["howto"]
draft = false
+++

At some point I was struggling to get access to my Gmail account. Since I usually block unwanted scripts from running on my computer, Google likes to flag my Gmail login attempts as suspicious activity. This would be fine if it didn't also make one of my only alternative identification methods an SMS. If I were to lose my phone or number I could be locked out of my account. Most accounts I have assume I have access to this email, thus a good chunk of modern life requires me accessing it, the prospect of becoming unable to log in seems quite realistic. [This](https://www.migadu.com/blog/gmail/) post (by an email-hosting company) builds a case against Gmail ground of privacy. It was at last time to get my own domain and control over my email. I also started this blog this year and it is pleasing to give it a nice `.com` home.


## 'Yer a domain, Harry {#yer-a-domain-harry}

Buy a domain from a domain provider. Common options are CloudFare, GoDaddy and NameCheap. I used CloudFare due to mixed comments online about customer service on the others. Also, NameCheap [may](https://news.ycombinator.com/item?id=44134152) pre-purchase domains that were looked up on domain search engines. If you are paranoid like me you can use [whois](https://tracker.debian.org/pkg/whois) (though it is being [sunset](https://www.icann.org/en/announcements/details/icann-update-launching-rdap-sunsetting-whois-27-01-2025-en), I'd suggest looking for an alternative). Once you find a domain name you like and is available just pay for it, you can get it for up to 10-years at a time.


## Buy email hosting services and link them to the domain {#buy-email-hosting-services-and-link-them-to-the-domain}

Doing some research (mostly HackerNews and Reddit comments) I narrowed down options to either [Migadu](https://migadu.com/) and [MXroute](https://mxroute.com/). `Migadu` had a free trial, so  I gave it a shot, but in the end I went for `MXroute` due to a promo they had at the time.

Make an email account. On Migadu it should be straightforward. In the case of `MXroute`, you have to pay at this point. the URL for management should be `<SERVER>.mxrouting.net:2222`, were `<SERVER>` is in the confirmation email. Once you have access to your email hosting server you can to link it to your domain.


### Link email service to domain {#link-email-service-to-domain}

The first step once you have an account is to add DNS (Domain Name Service) records to the website. They are instructions stored in servers that provide information about how to handle requests, mostly linking names to IPs.


#### Migadu {#migadu}

-   Export the BIND records into a file and download it
-   Load this file, add them CloudFare DNS records
-   If the `DKMS` and `ARC` keys fail, make sure to untoggle the `proxy` switch on their records


#### MXroute {#mxroute}

Mostly follow the [instructions](https://gist.github.com/afermg/69df5d99ddc7e1201b471aa6eb564e51) sent upon registration, but it is basically the same as Migadu but without the import/export convenience. For instance, one of the MX records (with different fields separated by commas) is `MX, <domain.com>, <server>.mxrouting.net`. The ones I had to copy over from the email were:

-   TXT records: `spf1` and `DKIM1`
-   MX records: `<SERVER>.mxrouting.net` and `<SERVER>-relay.mxrouting.net`

    Copy them on Cloudfare, specifically on DNS records:

<!--listend-->

```text
Cloudfare's domain home -> DNS Records -> Add record
```


### Test that is working {#test-that-is-working}

-   Log-in to yor account on `webmail.migadu.com` or `<SERVER>.mxrouting.net/roundcube`
-   Create an account for your first user
-   Send an mail to yourself to validate that it works.


### Optional: Set subdomain for server access {#optional-set-subdomain-for-server-access}

To access my email from my phone's Thunderbird App I had to set a subdomain. Only `MXroute` required this.

-   From the Control panel provided by `MXroute` the verification key
    ```text
    <SERVER>.mxrouting.net -> (sidebar) Account manager -> DNS record
    ```
    And add it as a TXT record on CloudFare
-   Add `mail.<domain.com>`  and/or `webmail.<domain.com>` subdomain(s) on CloudFare


## Link Github Pages website to domain {#link-github-pages-website-to-domain}

If we have one, we can also link our website to the domain. Some companies like to use `blog.<domain.com>` for blogs and keep `<domain.com>` for their landing page, but since I am almost certainly a person I skipped the subdomain approach (and used the so-called apex domain). In my case I am using Github to host my website, so I followed their [instructions](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site):

1.  Go to DNS records
    ```text
    Cloudfare's domain home -> DNS Records -> Add record
    ```
2.  Add `A` records to CloudFare (e.g., `A,<domain.com>,<185.ipv4.github.address>`)
3.  Add `CNAME,www,<user>.github.io` record. This step wasn't specified on the Github docs but I found it to be necessary for some reason.it
4.  Add cloudfare rules to redirect https
    ```text
    Cloudfare's domain home -> Cloudfare rules -> Templates -> Redirect http to HTTPS -> Deploy
    ```
5.  Add custom domain to github pages:
    ```text
    Github repo -> settings -> pages on side panel -> Custom domain
    ```
6.  Also on Github, the `Enforce HTTPS` checkbox, if the rest was properly configured it should work without a hitch


## Conclusions {#conclusions}

I like that I have control over my email, and I could even give my family and friends their personal emails (if I had any who actually wanted that). The first time I did all this it took me around three hours, mostly because Github could not find my DNS records. Since I have my domain now I can probably do more fun stuff, such as self-hosting tools to share with friends and family.
