# full ui -----------------------------------------------------------------

# page
fluidPage(

  # settings
  theme = shinytheme("darkly"),

  # spacing
  br(),
  br(),

  # row
  fluidRow(

    # column
    column(width = 10, offset = 1, align = "center",

      # prediction
      htmlOutput("img_pred_title"),
      br(),
      htmlOutput("img_pred_subtitle"),

      # spacing
      br(),
      br(),

      # image model
      switchInput(inputId = "img_mode",
        label = "Digit colour",
        onLabel = "Bright",
        offLabel = "Dark",
        value = TRUE,
        labelWidth = 300,
        handleWidth = 300,
        width = 450
      ),

      # spacing
      br(),
      br(),

      # image plot
      plotOutput("img_output"),

      # spacing
      br(),
      br(),
      br(),

      # file input
      fileInput(inputId = "img",
        label = "Choose an image",
        buttonLabel = "Browse",
        placeholder = "No image selected",
        accept = c('image/png', 'image/jpeg'),
        multiple = FALSE
      )

    )

  )

)
