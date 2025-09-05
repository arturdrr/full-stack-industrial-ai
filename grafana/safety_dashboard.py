safety_panels = [
    {
        "title": "🚨 Loop Detection Rate",
        "type": "stat",
        "query": "sum(loops_detected_total)"
    },
    {
        "title": "⏱️ Average Response Time",
        "type": "graph", 
        "query": "avg(agent_response_time)"
    },
    {
        "title": "💰 Cost Per Session",
        "type": "histogram",
        "query": "histogram_quantile(0.95, cost_per_session)"
    },
    {
        "title": "🔄 Agent Call Chains",
        "type": "sankey",
        "query": "agent_routing_flow"
    }
]
