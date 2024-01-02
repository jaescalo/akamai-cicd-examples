
data "akamai_property_rules_builder" "dev-gitlab-pipeline-demo_rule_default" {
  rules_v2023_10_30 {
    name      = "default"
    is_secure = true
    comments  = "The behaviors in the Default Rule apply to all requests for the property hostname(s) unless another rule overrides the Default Rule settings."
    behavior {
      origin {
        net_storage {
          cp_code              = 405092
          download_domain_name = "gsstrip.download.akamai.com"
          g2o_token            = "405092=6G96eY0RZK5O3Eb2xYVFzfzt8Pn8fZ37Cnv93266KVNB1U6VF1"
        }
        origin_type = "NET_STORAGE"
      }
    }
    behavior {
      base_directory {
        value = "/jaescalo/static-sites/"
      }
    }
    behavior {
      cp_code {
        value {
          id = 407946
        }
      }
    }
    behavior {
      allow_post {
        allow_without_content_length = false
        enabled                      = true
      }
    }
    behavior {
      real_user_monitoring {
        enabled = true
      }
    }
    children = [
      data.akamai_property_rules_builder.dev-gitlab-pipeline-demo_rule_performance.json,
      data.akamai_property_rules_builder.dev-gitlab-pipeline-demo_rule_offload.json,
    ]
  }
}

data "akamai_property_rules_builder" "dev-gitlab-pipeline-demo_rule_performance" {
  rules_v2023_10_30 {
    name                  = "Performance"
    comments              = "Improves the performance of delivering objects to end users. Behaviors in this rule are applied to all requests as appropriate."
    criteria_must_satisfy = "all"
    behavior {
      enhanced_akamai_protocol {
        display = ""
      }
    }
    behavior {
      http2 {
        enabled = ""
      }
    }
    behavior {
      allow_transfer_encoding {
        enabled = true
      }
    }
    behavior {
      remove_vary {
        enabled = true
      }
    }
    behavior {
      sure_route {
        enable_custom_key = false
        enabled           = true
        force_ssl_forward = false
        race_stat_ttl     = "30m"
        test_object_url   = "/akamai/sure-route-test-object.html"
        to_host_status    = "INCOMING_HH"
        type              = "PERFORMANCE"
      }
    }
    behavior {
      prefetch {
        enabled = true
      }
    }
    children = [
      data.akamai_property_rules_builder.dev-gitlab-pipeline-demo_rule_compressible_objects.json,
    ]
  }
}

data "akamai_property_rules_builder" "dev-gitlab-pipeline-demo_rule_offload" {
  rules_v2023_10_30 {
    name                  = "Offload"
    comments              = "Controls caching, which offloads traffic away from the origin. Most objects types are not cached. However, the child rules override this behavior for certain subsets of requests."
    criteria_must_satisfy = "all"
    behavior {
      caching {
        behavior        = "MAX_AGE"
        must_revalidate = false
        ttl             = "12d"
      }
    }
    behavior {
      cache_error {
        enabled        = true
        preserve_stale = true
        ttl            = "10s"
      }
    }
    behavior {
      downstream_cache {
        allow_behavior = "LESSER"
        behavior       = "ALLOW"
        send_headers   = "CACHE_CONTROL_AND_EXPIRES"
        send_private   = false
      }
    }
    behavior {
      tiered_distribution {
        enabled = true
      }
    }
    children = [
      data.akamai_property_rules_builder.dev-gitlab-pipeline-demo_rule_css_and_java_script.json,
      data.akamai_property_rules_builder.dev-gitlab-pipeline-demo_rule_static_objects.json,
      data.akamai_property_rules_builder.dev-gitlab-pipeline-demo_rule_uncacheable_responses.json,
    ]
  }
}

data "akamai_property_rules_builder" "dev-gitlab-pipeline-demo_rule_compressible_objects" {
  rules_v2023_10_30 {
    name                  = "Compressible Objects"
    comments              = "Compresses content to improve performance of clients with slow connections. Applies Last Mile Acceleration to requests when the returned object supports gzip compression."
    criteria_must_satisfy = "all"
    criterion {
      content_type {
        match_case_sensitive = false
        match_operator       = "IS_ONE_OF"
        match_wildcard       = true
        values               = ["text/*", "application/javascript", "application/x-javascript", "application/x-javascript*", "application/json", "application/x-json", "application/*+json", "application/*+xml", "application/text", "application/vnd.microsoft.icon", "application/vnd-ms-fontobject", "application/x-font-ttf", "application/x-font-opentype", "application/x-font-truetype", "application/xmlfont/eot", "application/xml", "font/opentype", "font/otf", "font/eot", "image/svg+xml", "image/vnd.microsoft.icon", ]
      }
    }
    behavior {
      gzip_response {
        behavior = "ALWAYS"
      }
    }
  }
}

data "akamai_property_rules_builder" "dev-gitlab-pipeline-demo_rule_css_and_java_script" {
  rules_v2023_10_30 {
    name                  = "CSS and JavaScript"
    comments              = "Overrides the default caching behavior for CSS and JavaScript objects that are cached on the edge server. Because these object types are dynamic, the TTL is brief."
    criteria_must_satisfy = "any"
    criterion {
      file_extension {
        match_case_sensitive = false
        match_operator       = "IS_ONE_OF"
        values               = ["css", "js", ]
      }
    }
    behavior {
      caching {
        behavior        = "MAX_AGE"
        must_revalidate = false
        ttl             = "66d"
      }
    }
    behavior {
      prefresh_cache {
        enabled     = true
        prefreshval = 90
      }
    }
    behavior {
      prefetchable {
        enabled = true
      }
    }
  }
}

data "akamai_property_rules_builder" "dev-gitlab-pipeline-demo_rule_static_objects" {
  rules_v2023_10_30 {
    name                  = "Static Objects"
    comments              = "Overrides the default caching behavior for images, music, and similar objects that are cached on the edge server. Because these object types are static, the TTL is long."
    criteria_must_satisfy = "any"
    criterion {
      file_extension {
        match_case_sensitive = false
        match_operator       = "IS_ONE_OF"
        values               = ["aif", "aiff", "au", "avi", "bin", "bmp", "cab", "carb", "cct", "cdf", "class", "doc", "dcr", "dtd", "exe", "flv", "gcf", "gff", "gif", "grv", "hdml", "hqx", "ico", "ini", "jpeg", "jpg", "mov", "mp3", "nc", "pct", "pdf", "png", "ppc", "pws", "swa", "swf", "txt", "vbs", "w32", "wav", "wbmp", "wml", "wmlc", "wmls", "wmlsc", "xsd", "zip", "pict", "tif", "tiff", "mid", "midi", "ttf", "eot", "woff", "woff2", "otf", "svg", "svgz", "webp", "jxr", "jar", "jp2", ]
      }
    }
    behavior {
      caching {
        behavior        = "MAX_AGE"
        must_revalidate = false
        ttl             = "7d"
      }
    }
    behavior {
      prefresh_cache {
        enabled     = true
        prefreshval = 90
      }
    }
    behavior {
      prefetchable {
        enabled = true
      }
    }
  }
}

data "akamai_property_rules_builder" "dev-gitlab-pipeline-demo_rule_uncacheable_responses" {
  rules_v2023_10_30 {
    name                  = "Uncacheable Responses"
    comments              = "Overrides the default downstream caching behavior for uncacheable object types. Instructs the edge server to pass Cache-Control and/or Expire headers from the origin to the client."
    criteria_must_satisfy = "all"
    criterion {
      cacheability {
        match_operator = "IS_NOT"
        value          = "CACHEABLE"
      }
    }
    behavior {
      downstream_cache {
        behavior = "TUNNEL_ORIGIN"
      }
    }
  }
}
