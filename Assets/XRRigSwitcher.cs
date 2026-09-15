using System;
using UnityEngine;

public class XRRigSwitcher : MonoBehaviour
{
   [SerializeField] private GameObject _XRRig;
   [SerializeField] private GameObject _debugRig;
   
   private void OnEnable()
   {
      DebugUISwitcher.Switch += Switch;
   }

   private void OnDisable()
   {
      DebugUISwitcher.Switch -= Switch;
   }

   private void Switch(bool on)
   {
      _XRRig.SetActive(!on);
      _debugRig.SetActive(on);
   }
   
}
