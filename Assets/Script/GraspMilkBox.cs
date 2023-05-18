using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class GraspMilkBox : MonoBehaviour
{
    public Transform graspPoint;
    public GameObject milkBox;
    public GameObject player;
    public bool isGrasping;
    public bool isHit;
    public bool ableMove;
    public LayerMask GroundLayer;
    public float GroundDistance;
    bool positionSet;
    Animator playerAni;
    public bool isGraspGun;
    public GameObject gunMode;
    public GameObject playerGunMode;

    public Transform restGunPoint;
    Animator myAni;

    // Start is called before the first frame update
    void Start()
    {
        isGrasping = false;
        isHit = false;
        positionSet = false;
    }

    // Update is called once per frame
    void Update()
    {
        ReleaseMilkBox();

        var raycastAll1 = Physics.RaycastAll(transform.position, Vector3.down, GroundDistance, GroundLayer);
        var raycastAll2 = Physics.RaycastAll(transform.position, Vector3.down, GroundDistance, GroundLayer);
        if (raycastAll1.Length > 0)
        {
            // 在地面
            ableMove = true;
           // Debug.Log("On Ground");
        }
        else
        {
            // 离地
            ableMove = false;
            //Debug.Log("Leave Ground");
        }

        if (positionSet)
        {
            milkBox.transform.position = graspPoint.position;
        }

    }


    private void ReleaseMilkBox()
    {
        if ((isGrasping&& player.GetComponent<PlayerMovement>().ropeKeyValue == 1)||isHit||MilkBoxSettings.bulletRemain==0)
        {           
            //Debug.Log("Release");
            if (milkBox)
            {
                milkBox.transform.parent = null;
                milkBox.GetComponent<Rigidbody>().useGravity = true;
                milkBox.GetComponent<MilkBoxSettings>().ableToTake = true;
                positionSet = false;
                isHit = false;
                isGraspGun = false;
                gunMode.SetActive(false);
                
                StartCoroutine(Wait2GraspMilkBox());
            }
        }
    }

    IEnumerator Wait2GraspMilkBox()
    {
        yield return new WaitForSeconds(1f);
        isGrasping = false;
        if (MilkBoxSettings.bulletRemain == 0 && milkBox.name == "Gun")
        {
            milkBox.transform.position = restGunPoint.position;
            MilkBoxSettings.bulletRemain = 6;
        }
    }



    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("MilkBox")&&isGrasping==false&&gameObject.GetComponentInParent<PlayerMovement>().ableMove)
        {
            Debug.Log("Grasp");
            milkBox = collision.gameObject;
            if (milkBox.GetComponent<MilkBoxSettings>().ableToTake)
            {
                if (milkBox.name=="Gun")
                {
                    isGraspGun=true;
                    gunMode.SetActive(true);
                }
                milkBox.GetComponent<Rigidbody>().useGravity = false;

                collision.transform.parent = gameObject.transform;
                milkBox.GetComponent<Rigidbody>().velocity = Vector3.zero;
                milkBox.GetComponent<Rigidbody>().angularVelocity = Vector3.zero;
                collision.transform.position = graspPoint.transform.position;
                milkBox.GetComponent<MilkBoxSettings>().ableToTake = false;
                isGrasping = true;
                positionSet = true;
                milkBox.GetComponent<MilkBoxSettings>().playerOrder = GetComponentInParent<PlayerInput>().playerIndex;
            }
        }
    }
    
}
