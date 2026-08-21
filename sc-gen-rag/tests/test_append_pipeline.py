import pytest
import json
import time

@pytest.fixture
def mock_llm_client(monkeypatch):
    class MockClient:
        def __init__(self, *args, **kwargs):
            pass
        def generate(self, prompt, sys_prompt, *args, **kwargs):
            if "TASK: Output the UPDATED composition state" in prompt:
                return "Mocked state update", {"tokens": 10}
            return "(SinOsc.ar).play", {"tokens": 50}
            
    import gui_backend
    monkeypatch.setattr(gui_backend, '_resolve_model', lambda x: ("mock", "mock-model"))
    
    # We must patch the LLMClient inside the function scope or globally
    import sys
    import types
    fake_module = types.ModuleType("llm_engine")
    fake_module.LLMClient = MockClient
    sys.modules["llm_engine"] = fake_module
    
    yield MockClient
    if "llm_engine" in sys.modules:
        del sys.modules["llm_engine"]


def test_append_returns_code(mock_llm_client, capture_daemon_stdout, monkeypatch):
    import gui_backend
    monkeypatch.setattr(gui_backend, 'config', type('obj', (object,), {'AVAILABLE_MODELS': {}}))
    monkeypatch.setattr(gui_backend, 'utils', type('obj', (object,), {'append_to_session_log': lambda *args, **kwargs: None}))
    monkeypatch.setattr(gui_backend, '_read_scd', lambda x: "")
    
    res = gui_backend.cmd_append({
        "prompt": "test",
        "active_file": "test.scd",
        "use_kb": False
    })
    
    assert res["code"] == "(SinOsc.ar).play"
    assert "last_stats" in res


def test_append_with_composition_state_caching(mock_llm_client, capture_daemon_stdout, monkeypatch):
    import gui_backend
    monkeypatch.setattr(gui_backend, 'config', type('obj', (object,), {'AVAILABLE_MODELS': {}}))
    monkeypatch.setattr(gui_backend, 'utils', type('obj', (object,), {'append_to_session_log': lambda *args, **kwargs: None}))
    monkeypatch.setattr(gui_backend, '_read_scd', lambda x: "")
    
    # Pre-populate cache
    gui_backend._composition_states["test.scd"] = "Cached State"
    

    # Check what the mock received. Since we don't have easy spy access, 
    # we can just test the return value which includes new_composition_state
    # Wait, new_composition_state returns the OLD state before the background update
    # In cmd_append: 
    # return {"code": code, "new_composition_state": composition_state, "last_stats": stats_dict}
    # It should return "Cached State" not "Old State"
    res = gui_backend.cmd_append({
        "prompt": "test",
        "active_file": "test.scd",
        "composition_state": "Active Ndefs: \\kick",
    })
    
    assert res["new_composition_state"] == "Cached State"


def test_append_fires_background_state_update(mock_llm_client, capture_daemon_stdout, monkeypatch):
    import gui_backend
    monkeypatch.setattr(gui_backend, 'config', type('obj', (object,), {'AVAILABLE_MODELS': {}}))
    monkeypatch.setattr(gui_backend, 'utils', type('obj', (object,), {'append_to_session_log': lambda *args, **kwargs: None}))
    monkeypatch.setattr(gui_backend, '_read_scd', lambda x: "")
    
    gui_backend._composition_states.clear()
    
    gui_backend.cmd_append({
        "prompt": "test",
        "active_file": "test2.scd",
        "use_kb": False
    })
    
    # The background thread updates the state
    time.sleep(0.5)
    
    assert "test2.scd" in gui_backend._composition_states
    assert gui_backend._composition_states["test2.scd"] == "Mocked state update"
