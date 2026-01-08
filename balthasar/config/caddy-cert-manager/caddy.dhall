{ apps.tls
  =
  { certificates.automate = [ "magisystem.xyz" ]
  , automation.policies
    =
    [ { issuers =
        [ { module = "acme"
          , email = "srsh@magisystem.xyz"
          , challenges =
            { http.alternate_port = 8443, tls-alpn.alternate_port = 8443 }
          }
        ]
      }
    ]
  }
}
