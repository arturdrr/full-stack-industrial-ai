class SafetyTests:
    async def test_loop_prevention(self):
        """Testa prevenção de loops"""
        
        # Simular sequência que geraria loop
        router = UltraIntelligentRouter()
        
        # Enviar mesma query múltiplas vezes
        for i in range(15):  # Acima do limite
            try:
                await router.route_request(
                    "What is Python?", 
                    {"session_id": "test_loop"}
                )
            except LoopDetectedException:
                assert i >= 10, "Loop deve ser detectado após 10 tentativas"
                return
                
        assert False, "Loop não foi detectado"
    
    async def test_context_compression(self):
        """Testa compressão de contexto"""
        
        manager = SmartContextManager()
        
        # Criar contexto muito grande
        large_context = {"history": ["query"] * 10000}
        
        compressed = await manager.manage_context(
            "test query", 
            [], 
            large_context
        )
        
        assert len(str(compressed)) < len(str(large_context))
    
    async def test_cost_limits(self):
        """Testa limites de custo"""
        
        safety = SafetyController()
        
        # Simular sessão cara
        safety.call_history["expensive_session"] = [
            {"cost": 0.50}, {"cost": 0.60}, {"cost": 0.70}, {"cost": 0.80}
        ]
        
        assert safety._check_limits_exceeded("expensive_session") == True
