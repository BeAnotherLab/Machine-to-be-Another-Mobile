using System.Collections;
using UnityEngine;

public class WaitAndDisable : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        StartCoroutine(WaitAndSelfDisable());
    }

    private IEnumerator WaitAndSelfDisable()
    {
        yield return new WaitForSeconds(1f);
        gameObject.SetActive(false);
    }
   
}
