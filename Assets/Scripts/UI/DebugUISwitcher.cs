using UnityEngine;
using UnityEngine.XR;

public class DebugUISwitcher : MonoBehaviour
{
    private bool _UIOn;
    private bool _buttonRelease = true;

    public delegate void OnSwitch(bool on);
    public static OnSwitch Switch = delegate {};

    
    [SerializeField] private GameObject _inspectorCanvas;
    [SerializeField] private GameObject _standaloneSettingsUI;
    [SerializeField] private GameObject _inGameDebugConsole;

    private void Update()
    {
        var rightHandDevice = InputDevices.GetDeviceAtXRNode(XRNode.RightHand);

        if (!rightHandDevice.isValid) return;

        // Read both button states.
        bool aPressed = rightHandDevice.TryGetFeatureValue(CommonUsages.primaryButton, out bool primaryButton) && primaryButton;
        bool triggerPressed = rightHandDevice.TryGetFeatureValue(CommonUsages.trigger, out float triggerValue) && triggerValue > 0.5f;

        // Both buttons must be released before another UI switch is allowed.
        if (!aPressed && !triggerPressed)
        {
            _buttonRelease = true;
            return;
        }
        
        if (aPressed && triggerPressed && _buttonRelease) // Both buttons are pressed. Only switch if they were released since the previous switch.
        {
            _buttonRelease = false;

            _UIOn = !_UIOn;

            Switch(_UIOn);
            _inspectorCanvas.SetActive(_UIOn);
            _standaloneSettingsUI.SetActive(_UIOn);
            _inGameDebugConsole.SetActive(_UIOn);
        }
    }
}