*** UI 结构图
graph TB
    subgraph "核心视图层"
        KV[KLineView<br/>主容器视图]
    end
    
    subgraph "展示层 (Presentation Layer)"
        CHART[KLineChartView<br/>图表视图]
        DETAIL[KLineDetailView<br/>详情面板]
        CONTROL[KTechnicalIndicatorControlView<br/>指标控制]
        MAIN_TEXT[KMainIndicatorTextView<br/>主图指标文本]
    end
    
    subgraph "渲染层 (Rendering Layer)"
        CANDLE[蜡烛图层<br/>candleLayers]
        CROSS[交叉轴图层<br/>crosscCandleLayer]
        CROSSLINE[十字线容器层<br/>crossLineContainerLayer]
        SECOND[KLineSeconedLayer<br/>副图指标层]
    end
    
    subgraph "指标渲染器 (Indicator Renderers)"
        MACD_R[MACDIndicatorRenderer]
        KDJ_R[KDJIndicatorRenderer]
        RSI_R[RSIIndicatorRenderer]
        VOL_R[VolumeIndicatorRenderer]
        WR_R[WRIndicatorRenderer]
    end
    
    subgraph "交互层 (Interaction Layer)"
        SCALE_MGR[KLineScaleGestureManager<br/>缩放手势]
        TAP_MGR[KLineTapLongGestureManager<br/>点击长按手势]
    end
    
    %% 连接关系
    KV --> CHART
    KV --> DETAIL
    KV --> CONTROL
    KV --> SCALE_MGR
    KV --> TAP_MGR
    
    CHART --> CANDLE
    CHART --> CROSS
    CHART --> CROSSLINE
    CHART --> SECOND
    CHART --> MAIN_TEXT
    
    SECOND --> MACD_R
    SECOND --> KDJ_R
    SECOND --> RSI_R
    SECOND --> VOL_R
    SECOND --> WR_R
    
    %% 样式
    classDef coreLayer fill:#e3f2fd,stroke:#0277bd,stroke-width:3px
    classDef presentationLayer fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef renderingLayer fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    classDef indicatorLayer fill:#fff8e1,stroke:#f57f17,stroke-width:2px
    classDef interactionLayer fill:#f1f8e9,stroke:#33691e,stroke-width:2px
    
    class KV coreLayer
    class CHART,DETAIL,CONTROL,MAIN_TEXT presentationLayer
    class CANDLE,CROSS,CROSSLINE,SECOND renderingLayer
    class MACD_R,KDJ_R,RSI_R,VOL_R,WR_R indicatorLayer
    class SCALE_MGR,TAP_MGR interactionLayer
