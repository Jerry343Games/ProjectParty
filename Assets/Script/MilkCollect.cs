using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class MilkCollect : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerEnter(Collider other)
    {
        GameObject player = other.transform.parent.gameObject;
        int i = player.GetComponent<PlayerInput>().playerIndex;
        PlayerIndentify.scoreNum[0]++;
        Debug.Log("collect");
        Destroy(this);
    }
}
